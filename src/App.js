import { useRef, useState, useEffect } from 'react';
import './App.css';

import * as poseDetection from '@tensorflow-models/pose-detection';
import * as tf from '@tensorflow/tfjs-core';
import '@tensorflow/tfjs-backend-webgl';
import Webcam from 'react-webcam';

import calculateHeadRotation from './calculateHeadRotation';

function App() {

  const [rotation, setRotation] = useState(0);

  const INFERENCES_PER_REFRESH_INTERVAL = 1;
  const PREDICTION_INTERVAL_MS = 200;
  const webcamRef = useRef(null);

  const runMoveNet = async () => {
    const detectorConfig = { modelType: poseDetection.movenet.modelType.SINGLEPOSE_THUNDER };
    const detector = await poseDetection.createDetector(
      poseDetection.SupportedModels.MoveNet, detectorConfig
    );

    console.log('Starting setInterval...');
    setInterval(() => {
      detect(detector);
    }, PREDICTION_INTERVAL_MS);
  };

  const detect = async (detector) => {
    const isCamDefined = () => typeof webcamRef.current !== "undefined";
    const isCamNull = () => webcamRef.current == null;
    const isCamReady = () => webcamRef.current.video.readyState === 4;

    if (isCamDefined() && !isCamNull() && isCamReady()) {
      const video = webcamRef.current.video;
      const pose = await detector.estimatePoses(video);

      const isKeypointsDefined = () => typeof pose[0].keypoints !== "undefined";

      if (isKeypointsDefined()) {
        const tmp = calculateHeadRotation(pose);
        setRotation(tmp);
      }
    }
  }

  // Run only on startup.
  useEffect(runMoveNet, []);

  return (
    <div className="App">
      <header className="App-header">
        <p>Head rotation: {rotation.toFixed(4)}</p>
        <Webcam ref={webcamRef} mirrored={true} />
      </header>
    </div>
  );
}

export default App;