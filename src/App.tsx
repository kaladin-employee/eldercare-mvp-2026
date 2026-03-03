import { useEffect } from 'react'
import { Routes, Route, useSearchParams } from 'react-router-dom'
import './App.css'

function ElderHome() {
  return <h1>ElderCare Station - Elder Home</h1>;
}

function CaregiverDashboard() {
  return <h1>ElderCare Station - Caregiver Dashboard</h1>;
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
