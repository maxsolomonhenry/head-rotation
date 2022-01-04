export function convertRotationToMidiRange(rotationValue) {
  // Clamp.
  rotationValue = Math.min(1, rotationValue);
  rotationValue = Math.max(-1, rotationValue);

  // Scale to 0 - 127.
  rotationValue = (rotationValue + 1) * 63.5;

  return Math.round(rotationValue);
}

export function calculateHeadRotation(pose) {

  let nose = pose[0].keypoints[0];
  let leftEye = pose[0].keypoints[1];
  let rightEye = pose[0].keypoints[2];

  // Set left eye as origin.
  rightEye = subtractKeypoint(rightEye, leftEye);
  nose = subtractKeypoint(nose, leftEye);

  // Rotate so rightEye is flat on X-axis.
  const angle = findAngle(rightEye);
  rightEye = rotateKeypoint(rightEye, -angle);
  nose = rotateKeypoint(nose, -angle);

  // Express nose location as normalized [-1, 1] between eyes.
  let headRotation = (nose.x / rightEye.x) - 0.5;

  return headRotation;
}

function subtractKeypoint(minuend, subtrahend) {
  minuend.x -= subtrahend.x;
  minuend.y -= subtrahend.y;

  return minuend;
}

function findAngle(keypoint) {
  return Math.atan(keypoint.y / keypoint.x);
}

function rotateKeypoint(keypoint, angle) {
  const x = keypoint.x;
  const y = keypoint.y;

  keypoint.x = Math.cos(angle) * x - Math.sin(y);
  keypoint.y = Math.sin(angle) * x + Math.cos(y);

  return keypoint;
}