import { useRef, useState, useEffect } from 'react';
import './App.css';

import * as poseDetection from '@tensorflow-models/pose-detection';
import * as tf from '@tensorflow/tfjs-core';
import '@tensorflow/tfjs-backend-webgl';
import Webcam from 'react-webcam';
import { WebMidi } from 'webmidi';

import { calculateHeadRotation, convertRotationToMidiRange, fold } from './utilities';

function App() {

  const [rotation, setRotation] = useState(0);

  const PREDICTION_INTERVAL_MS = 5;

  const MIDI_CC_FULLRANGE = 3;
  const MIDI_CC_FOLDEDRANGE = 4;

  const webcamRef = useRef(null);

  const runMoveNet = async () => {

    // Init neural net.
    const detectorConfig = { modelType: poseDetection.movenet.modelType.SINGLEPOSE_THUNDER };
    const detector = await poseDetection.createDetector(
      poseDetection.SupportedModels.MoveNet, detectorConfig
    );

    // Init WebMidi output.
    await WebMidi.enable();

    const output = WebMidi.getOutputByName("IAC Driver Bus 1");
    const channel = output.channels[1];

    console.log('Starting setInterval...');
    setInterval(() => {
      detect(detector, channel);
    }, PREDICTION_INTERVAL_MS);
  };

  const detect = async (detector, channel) => {
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

        const midiVal = convertRotationToMidiRange(tmp);
        const foldedVal = fold(midiVal);

        channel.sendControlChange(MIDI_CC_FULLRANGE, Math.round(midiVal));

        // Useful for fully left/right oriented sources.
        channel.sendControlChange(MIDI_CC_FOLDEDRANGE, Math.round(foldedVal))
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