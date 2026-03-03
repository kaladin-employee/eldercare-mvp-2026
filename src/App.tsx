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

  const handleCheckIn = (type: string) => {
    const now = new Date().toISOString();
    console.log(`${type} check-in at`, now);
    setCheckIns(prev => [...prev, { type, time: now }]);
  };

  return (
    <>
      <h1>ElderCare Station - Elder Home</h1>
      <p>Current time: {time}</p>
      <button onClick={() => handleCheckIn('OK')} style={{fontSize: '2em', padding: '20px'}}>OK</button>
      <button onClick={() => handleCheckIn('Meds')} style={{fontSize: '2em', padding: '20px', background: '#ff8c00'}}>Meds</button>
      <button onClick={() => handleCheckIn('Meal')} style={{fontSize: '2em', padding: '20px', background: '#4682b4'}}>Meal</button>
    </>
  );
}

function CaregiverDashboard() {
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
    </Routes>
  );
}

export default App
