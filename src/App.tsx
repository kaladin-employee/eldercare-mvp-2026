import { Routes, Route } from 'react-router-dom'
import './App.css'

function ElderHome() {
  return <h1>ElderCare Station - Elder Home</h1>;
}

function CaregiverDashboard() {
  return <h1>ElderCare Station - Caregiver Dashboard</h1>;
}

function App() {
  return (
    <Routes>
      <Route path="/" element={<ElderHome />} />
      <Route path="/caregiver" element={<CaregiverDashboard />} />
    </Routes>
  );
}

export default App
