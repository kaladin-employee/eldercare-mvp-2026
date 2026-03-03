import { useEffect, useState } from 'react'
import { Routes, Route, useSearchParams } from 'react-router-dom'
import Settings from "./Settings";
import './App.css'

interface CheckIn {
  type: string;
  time: string;
}

function ElderHome() {
  const [time, setTime] = useState(new Date().toLocaleString());
  const [isDarkMode, setIsDarkMode] = useState(JSON.parse(localStorage.getItem("darkMode") || "false"));

  useEffect(() => { localStorage.setItem("darkMode", JSON.stringify(isDarkMode)); }, [isDarkMode]);

// @ts-ignore
  const handleToggleDarkMode = () => setIsDarkMode(!isDarkMode);
  const [checkIns, setCheckIns] = useState<CheckIn[]>(() => {
    const saved = localStorage.getItem('checkIns');
    return saved ? JSON.parse(saved) : [];
  });
  const [listening, setListening] = useState(false);
  const [reminder, setReminder] = useState(false);

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date().toLocaleString()), 1000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    localStorage.setItem('checkIns', JSON.stringify(checkIns));
  }, [checkIns]);

  useEffect(() => {
    const reminderTimer = setTimeout(() => setReminder(true), 4 * 60 * 60 * 1000);
    return () => clearTimeout(reminderTimer);
  }, []);

  const handleCheckIn = (type: string) => {
    const now = new Date().toISOString();
    console.log(`${type} check-in at`, now);
    setCheckIns(prev => [...prev, { type, time: now }]);
    if (type === 'Meds') setReminder(false);
  };

  const startVoice = () => {
    setListening(true);
    const recognition = new ((window as any).SpeechRecognition || (window as any).webkitSpeechRecognition)();
    recognition.onresult = (event: any) => {
      const transcript = event.results[0][0].transcript.toLowerCase();
      if (transcript.includes('ok')) handleCheckIn('OK');
      if (transcript.includes('meds')) handleCheckIn('Meds');
      if (transcript.includes('meal')) handleCheckIn('Meal');
      setListening(false);
    };
    recognition.onend = () => setListening(false);
    recognition.start();
  };

  return (
    <>
      <h1>ElderCare Station - Elder Home</h1>
<button onClick={() => window.location.href="/settings"} style={{fontSize: "1.5em", padding: "10px"}}>Settings</button>
<button onClick={() => window.location.href="/settings"} style={{fontSize: "1.5em", padding: "10px"}}>Settings</button>
      <button onClick={handleToggleDarkMode} style={{fontSize: "1.5em", padding: "10px"}}>{isDarkMode ? "Light Mode" : "Dark Mode"}</button>
      <p>Current time: {time}</p>
      {reminder && <p style={{color: 'orange'}}>Reminder: Time for meds!</p>}
      <button onClick={() => handleCheckIn('OK')} style={{fontSize: '2em', padding: '20px'}}>OK</button>
      <button onClick={() => handleCheckIn('Meds')} style={{fontSize: '2em', padding: '20px', background: '#ff8c00'}}>Meds</button>
      <button onClick={() => handleCheckIn('Meal')} style={{fontSize: '2em', padding: '20px', background: '#4682b4'}}>Meal</button>
      <button onClick={startVoice} style={{fontSize: '2em', padding: '20px', background: '#00bfff'}} disabled={listening}>
      <button onClick={() => navigator.clipboard.writeText(JSON.stringify({doctor: "+1234567890", hospital: "+0987654321", family: "+5555555555"}))} style={{fontSize: "2em", padding: "20px", background: "#ff0000"}}>Emergency</button>
        {listening ? 'Listening...' : 'Voice Input'}
      </button>
    </>
  );
}

function History() {
  const [isDarkMode, setIsDarkMode] = useState(JSON.parse(localStorage.getItem("darkMode") || "false"));

  useEffect(() => { localStorage.setItem("darkMode", JSON.stringify(isDarkMode)); }, [isDarkMode]);

// @ts-ignore
  const handleToggleDarkMode = () => setIsDarkMode(!isDarkMode);
  const [checkIns, setCheckIns] = useState<CheckIn[]>(() => {
    const saved = localStorage.getItem('checkIns');
    return saved ? JSON.parse(saved) : [];
  });

  useEffect(() => {
    const handleStorage = () => {
      const saved = localStorage.getItem('checkIns');
      setCheckIns(saved ? JSON.parse(saved) : []);
    };
    window.addEventListener('storage', handleStorage);
    return () => window.removeEventListener('storage', handleStorage);
  }, []);

  return (
    <>
      <h1>Check-In History</h1>
      <ul>
        {checkIns.map((ci, i) => <li key={i} style={{fontSize: '1.5em'}}>{ci.type} at {ci.time}</li>)}
      </ul>
    </>
  );
}

function CaregiverDashboard() {
  const [isDarkMode, setIsDarkMode] = useState(JSON.parse(localStorage.getItem("darkMode") || "false"));

  useEffect(() => { localStorage.setItem("darkMode", JSON.stringify(isDarkMode)); }, [isDarkMode]);

// @ts-ignore
  const handleToggleDarkMode = () => setIsDarkMode(!isDarkMode);
  const [checkIns, setCheckIns] = useState<CheckIn[]>(() => {
    const saved = localStorage.getItem('checkIns');
    return saved ? JSON.parse(saved) : [];
  });
  const [alert, setAlert] = useState(false);

  useEffect(() => {
    const handleStorage = () => {
      const saved = localStorage.getItem('checkIns');
      const newCheckIns = saved ? JSON.parse(saved) : [];
      setCheckIns(newCheckIns);
      const lastTime = newCheckIns.length > 0 ? new Date(newCheckIns[newCheckIns.length - 1].time).getTime() : 0;
      const now = Date.now();
      setAlert(now - lastTime > 12 * 60 * 60 * 1000);
    };
    window.addEventListener('storage', handleStorage);
    handleStorage();
    const interval = setInterval(handleStorage, 60000);
    return () => {
      window.removeEventListener('storage', handleStorage);
      clearInterval(interval);
    };
  }, []);

  const lastCheckIn = checkIns[checkIns.length - 1];

  return (
    <>
      <h1>ElderCare Station - Caregiver Dashboard</h1>
      {alert && <p style={{color: 'red'}}>Alert: No check-in in over 12 hours!</p>}
      <p>Last check-in: {lastCheckIn ? `${lastCheckIn.type} at ${lastCheckIn.time}` : 'None'}</p>
    </>
  );
}

function App() {
  const [searchParams] = useSearchParams();
  const mode = searchParams.get('mode') || localStorage.getItem('mode') || 'elder';

  useEffect(() => {
    localStorage.setItem('mode', mode);
  }, [mode]);

  return (
    <Routes>
      <Route path="/" element={mode === 'caregiver' ? <CaregiverDashboard /> : <ElderHome />} />
      <Route path="/caregiver" element={<CaregiverDashboard />} />
      <Route path="/history" element={<History />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  );
}

export default App
