import { useState, useEffect } from "react";

export default function Settings() {
  const [fontSize, setFontSize] = useState(parseInt(localStorage.getItem("fontSize") || "24"));
  const [voiceSpeed, setVoiceSpeed] = useState(parseInt(localStorage.getItem("voiceSpeed") || "150"));
  const [remindersEnabled, setRemindersEnabled] = useState(JSON.parse(localStorage.getItem("remindersEnabled") || "true"));

  useEffect(() => {
    localStorage.setItem("fontSize", fontSize.toString());
    document.documentElement.style.fontSize = `${fontSize}px`;
  }, [fontSize]);

  useEffect(() => { localStorage.setItem("voiceSpeed", voiceSpeed.toString()); }, [voiceSpeed]);
  useEffect(() => { localStorage.setItem("remindersEnabled", JSON.stringify(remindersEnabled)); }, [remindersEnabled]);

  return (
    <div>
      <h1>Settings</h1>
      <label>Font Size: <input type="range" min="16" max="32" value={fontSize} onChange={(e) => setFontSize(parseInt(e.target.value))} /></label>
      <br />
      <label>Voice Speed: <input type="range" min="50" max="300" step="50" value={voiceSpeed} onChange={(e) => setVoiceSpeed(parseInt(e.target.value))} /></label>
      <br />
      <label>Enable Reminders: <input type="checkbox" checked={remindersEnabled} onChange={(e) => setRemindersEnabled(e.target.checked)} /></label>
    </div>
  );
}
