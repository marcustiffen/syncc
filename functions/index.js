const admin = require("firebase-admin");
const functions = require("firebase-functions/v2");

admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();

// Utility function for batch operations
const processBatchOperation = async (operations, batchSize = 450) => {
  const chunks = [];
  for (let i = 0; i < operations.length; i += batchSize) {
    chunks.push(operations.slice(i, i + batchSize));
  }

  for (const chunk of chunks) {
    const batch = db.batch();
    chunk.forEach((op) => op(batch));
    await batch.commit();
  }
};

// Utility function for error handling
const handleHttpError = (res, error, message) => {
  console.error(`Error: ${message}:`, error);
  return res.status(500).send({error: message});
};

// Utility function for input validation
const validateRequest = (req, res, requiredFields) => {
  const missingFields = requiredFields.filter((field) => !req.body[field]);
  if (missingFields.length > 0) {
    res.status(400).send({
      error: `Missing required fields: ${missingFields.join(", ")}`,
    });
    return false;
  }
  return true;
};

exports.sendLike = functions.https.onRequest(async (req, res) => {
  if (!validateRequest(req, res, ["currentUserId", "likedUserId"])) return;
  const {currentUserId, likedUserId} = req.body;

  try {
    const timestamp = admin.firestore.FieldValue.serverTimestamp();
    const batch = db.batch();

    // Prepare like operations
    const likeOperations = [
      {
        ref: db.collection("users")
            .doc(currentUserId)
            .collection("likes_sent")
            .doc(likedUserId),
        data: {userId: likedUserId, timestamp},
      },
      {
        ref: db.collection("users")
            .doc(likedUserId)
            .collection("likes_received")
            .doc(currentUserId),
        data: {userId: currentUserId, timestamp},
      },
    ];

    likeOperations.forEach((op) => batch.set(op.ref, op.data));
    await batch.commit();

    // Check for match
    const matchExists = await db.collection("users")
        .doc(likedUserId)
        .collection("likes_sent")
        .doc(currentUserId)
        .get();

    if (matchExists.exists) {
      await initiateMatch(currentUserId, likedUserId);
      return res.status(200).send({status: "match", message: "It's a match!"});
    }

    return res.status(200).send(
        {status: "success", message: "Like sent successfully"},
    );
  } catch (error) {
    return handleHttpError(res, error, "Error sending like");
  }
});

exports.sendLikeFree = functions.https.onRequest(async (req, res) => {
  if (!validateRequest(req, res, ["currentUserId", "likedUserId"])) return;
  const {currentUserId, likedUserId} = req.body;

  try {
    const userRef = db.collection("users").doc(currentUserId);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      return res.status(404).send({status: "error", message: "User not found"});
    }

    const userData = userDoc.data();
    const now = new Date();

    // Replace optional chaining with plain check
    const lastReset = userData.lastLikeReset ?
      userData.lastLikeReset.toDate() : new Date(0);
    const dailyLikes = userData.dailyLikes !==
      undefined && userData.dailyLikes !==
      null ? userData.dailyLikes : 3;

    // Calculate hours since last reset
    const hoursSinceReset =
      (now.getTime() - lastReset.getTime()) / (1000 * 60 * 60);
    let updatedLikes = dailyLikes;

    if (hoursSinceReset >= 12) {
      updatedLikes = 3;
    }

    if (updatedLikes <= 0) {
      return res.status(403).send({status: "error", message: "LikeLimit"});
    }

    // Prepare batch
    const timestamp = admin.firestore.FieldValue.serverTimestamp();
    const batch = db.batch();

    const likeSentRef = db.collection("users")
        .doc(currentUserId)
        .collection("likes_sent")
        .doc(likedUserId);
    const likeReceivedRef = db.collection("users")
        .doc(likedUserId)
        .collection("likes_received")
        .doc(currentUserId);

    batch.set(likeSentRef, {userId: likedUserId, timestamp});
    batch.set(likeReceivedRef, {userId: currentUserId, timestamp});

    // Update dailyLikes and lastLikeReset
    const updates = {
      dailyLikes: updatedLikes - 1,
      lastLikeReset: updatedLikes === 3 ?
        admin.firestore.Timestamp.fromDate(now) :
        userData.lastLikeReset,
    };
    batch.update(userRef, updates);

    await batch.commit();

    // Check for match
    const matchDoc = await db.collection("users")
        .doc(likedUserId)
        .collection("likes_sent")
        .doc(currentUserId)
        .get();

    if (matchDoc.exists) {
      await initiateMatch(currentUserId, likedUserId);
      return res.status(200).send({status: "match", message: "It's a match!"});
    }

    return res.status(200).send({status: "success", message: "Like sent"});
  } catch (error) {
    console.error("Error in sendLikeFreemiumLimited:", error);
    return handleHttpError(res, error, "Error processing like");
  }
});


/**
 * Initiates a match between two users by updating their Firestore records.
 * Removes each user from the others `likes_sent` and `likes_received`
 collections
 * and adds them to each others `matches` collections.
 Also creates a chat room for them.
 *
 * @param {string} userAId - The ID of the first user.
 * @param {string} userBId - The ID of the second user.
 * @throws Will throw an error if the match initiation fails.
 */
async function initiateMatch(userAId, userBId) {
  const timestamp = admin.firestore.FieldValue.serverTimestamp();
  const operations = [];

  // Remove likes
  ["likes_sent", "likes_received"].forEach((collection) => {
    operations.push((batch) => {
      batch.delete(db.collection("users")
          .doc(userAId)
          .collection(collection)
          .doc(userBId));
      batch.delete(db.collection("users")
          .doc(userBId)
          .collection(collection)
          .doc(userAId));
    });
  });

  // Add matches
  operations.push((batch) => {
    const matchData = {timestamp};
    batch.set(
        db.collection("users").doc(userAId)
            .collection("matches")
            .doc(userBId),
        {...matchData, userId: userBId},
    );
    batch.set(
        db.collection("users").doc(userBId)
            .collection("matches")
            .doc(userAId),
        {...matchData, userId: userAId},
    );
  });

  // Create chat room
  operations.push((batch) => {
    const chatRoomRef = db.collection("chatRooms").doc();
    batch.set(chatRoomRef, {
      id: chatRoomRef.id,
      name: chatRoomRef.id,
      users: [userAId, userBId],
      createdAt: timestamp,
      lastMessageAt: timestamp,
    });
  });

  await processBatchOperation(operations);
}

exports.sendNotification = functions.https.onRequest(async (req, res) => {
  if (!validateRequest(req, res, [
    "token", "message", "title"],
  )) return;
  const {token, message, title} = req.body;

  try {
    const response = await admin.messaging().send({
      notification: {title, body: message},
      token,
    });

    return res.status(200).send({success: true, messageId: response});
  } catch (error) {
    return handleHttpError(res, error, "Error sending notification");
  }
});


exports.deleteUser = functions.https.onRequest(async (req, res) => {
  const {uid} = req.body;

  // Validate input
  if (!uid) {
    res.status(400).send("User ID is required.");
    return;
  }

  try {
    // Start a batch write for efficient multi-document deletion
    const batch = db.batch();

    // 1. Delete user's images from Firebase Storage
    const bucket = storage.bucket();
    await bucket.deleteFiles({
      prefix: `images/${uid}/`,
    });

    // 2. Delete the subcollections of the user
    const userRef = db.collection("users").doc(uid);
    const subcollections = [
      "likes_received",
      "likes_sent",
      "matches",
      "dismissed_users",
    ];

    // Delete all documents in each subcollection
    await Promise.all(subcollections.map(async (subcollName) => {
      const subcollRef = userRef.collection(subcollName);
      const snapshot = await subcollRef.get();

      snapshot.forEach((doc) => {
        batch.delete(doc.ref);
      });
    }));

    // 3. Delete the user document from the 'users' collection
    batch.delete(userRef);

    // 4. Delete user ref for other users.
    const users = await db.collection("users").get();

    for (const user of users.docs) {
      if (user.id === uid) continue;

      for (const subcollName of subcollections) {
        const subcoll = user.ref.collection(subcollName);
        const query = subcoll.where("userId", "==", uid);
        const refs = await query.get();

        refs.forEach((doc) => {
          batch.delete(doc.ref);
        });
      }
    }

    // 5. Delete chatrooms with user
    // Get all chatrooms where user is a participant
    const chatRoomsQuery = await db.collection("chatRooms")
        .where("users", "array-contains", uid)
        .get();

    // Delete messages subcollections first, handling batch limitations
    const messageDeletionPromises = chatRoomsQuery.docs.map(async (chatDoc) => {
      const messagesQuery = await chatDoc.ref.collection("messages").get();
      const messageChunks = [];
      const BATCH_SIZE = 450; // Firestore limit is 500, leaving some margin

      // Split messages into chunks
      for (let i = 0; i < messagesQuery.docs.length; i += BATCH_SIZE) {
        messageChunks.push(messagesQuery.docs.slice(i, i + BATCH_SIZE));
      }

      // Process each chunk with a new batch
      for (const chunk of messageChunks) {
        const messageBatch = db.batch();
        chunk.forEach((messageDoc) => {
          messageBatch.delete(messageDoc.ref);
        });
        await messageBatch.commit();
      }
    });

    // Wait for all message deletions to complete
    await Promise.all(messageDeletionPromises);

    // Then delete the chatroom documents
    const chatroomChunks = [];
    const BATCH_SIZE = 450;

    // Split chatrooms into chunks
    for (let i = 0; i < chatRoomsQuery.docs.length; i += BATCH_SIZE) {
      chatroomChunks.push(chatRoomsQuery.docs.slice(i, i + BATCH_SIZE));
    }

    // Delete chatrooms in chunks
    for (const chunk of chatroomChunks) {
      const chatroomBatch = db.batch();
      chunk.forEach((chatDoc) => {
        chatroomBatch.delete(chatDoc.ref);
      });
      await chatroomBatch.commit();
    }

    // Commit the batch
    await batch.commit();

    res.status(200).send("User deleted successfully.");
  } catch (error) {
    console.error("Error deleting user:", error);
    res.status(500).send("Error deleting user");
  }
});


exports.unmatchUser = functions.https.onRequest(async (req, res) => {
  if (!validateRequest(req, res, ["currentUserId", "unmatchedUserId"])) return;
  const {currentUserId, unmatchedUserId} = req.body;

  try {
    const timestamp = admin.firestore.FieldValue.serverTimestamp();
    const operations = [];

    // Remove matches
    operations.push((batch) => {
      batch.delete(db.collection("users")
          .doc(currentUserId)
          .collection("matches")
          .doc(unmatchedUserId));
      batch.delete(db.collection("users")
          .doc(unmatchedUserId)
          .collection("matches")
          .doc(currentUserId));
    });

    // Add to dismissed users
    operations.push((batch) => {
      const dismissData = {timestamp};
      batch.set(
          db.collection("users")
              .doc(currentUserId)
              .collection("dismissed_users")
              .doc(unmatchedUserId),
          {...dismissData, userId: unmatchedUserId},
      );
      batch.set(
          db.collection("users")
              .doc(unmatchedUserId)
              .collection("dismissed_users")
              .doc(currentUserId),
          {...dismissData, userId: currentUserId},
      );
    });

    // Delete chat rooms and messages
    const chatRooms = await db.collection("chatRooms")
        .where("users", "array-contains", currentUserId)
        .get();

    for (const chatRoom of chatRooms.docs) {
      if (!chatRoom.data().users.includes(unmatchedUserId)) continue;

      const messages = await chatRoom.ref.collection("messages").get();
      await processBatchOperation(
          messages.docs.map((doc) => (batch) => batch.delete(doc.ref)),
      );
      await chatRoom.ref.delete();
    }

    await processBatchOperation(operations);
    return res.status(200).send(
        {status: "success", message: "Users unmatched successfully"},
    );
  } catch (error) {
    return handleHttpError(res, error, "Error unmatching users");
  }
});
