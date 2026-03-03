import { useEffect, useState } from 'react'
import { Routes, Route, useSearchParams } from 'react-router-dom'
import './App.css'

interface CheckIn {
  type: string;
  time: string;
}

function ElderHome() {
  const [time, setTime] = useState(new Date().toLocaleString());
  const [checkIns, setCheckIns] = useState<CheckIn[]>(() => {
    const saved = localStorage.getItem('checkIns');
    return saved ? JSON.parse(saved) : [];
  });

  useEffect(() => {
    const timer = setInterval(() => setTime(new Date().toLocaleString()), 1000);
    return () => clearInterval(timer);
  }, []);

  useEffect(() => {
    localStorage.setItem('checkIns', JSON.stringify(checkIns));
  }, [checkIns]);

  const handleOK = () => {
    const now = new Date().toISOString();
    console.log('OK check-in at', now);
    setCheckIns(prev => [...prev, { type: 'OK', time: now }]);
  };

  return (
    <>
      <h1>ElderCare Station - Elder Home</h1>
      <p>Current time: {time}</p>
      <button onClick={handleOK} style={{fontSize: '2em', padding: '20px'}}>OK</button>
    </>
  );
}

function CaregiverDashboard() {
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

  const lastCheckIn = checkIns[checkIns.length - 1];

  return (
    <>
      <h1>ElderCare Station - Caregiver Dashboard</h1>
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
    </Routes>
  );
}

export default App
