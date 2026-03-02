import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Notification from 'notificationsjs'; // Assume this is installed or use standard Notification API

function App() {
  const [mode, setMode] = useState('elder');
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString());

  useEffect(() => {
    let intervalId;
    if (mode === 'elder') {
      intervalId = setInterval(() => {
        const nextReminder = new Date();
        nextReminder.setHours(nextReminder.getHours() + 4);
        Notification.requestPermission().then((permission) => {
          if (permission === 'granted') {
            Notification.scheduleNotification({ title: 'Med Reminder', body: 'Take your medication!', time: nextReminder });
          }
        });
      }, 30 * 60 * 1000); // Check every 30 minutes
    }

    return () => {
      clearInterval(intervalId);
    };
  }, [mode]);

  useEffect(() => {
    setInterval(() => {
      setCurrentTime(new Date().toLocaleTimeString());
    }, 1000);
  }, []);

  const checkIns = localStorage.getItem('checkIn');
  const recentCheckIns = checkIns ? checkIns.split(',').slice(-5) : [];
  const lastCheckIn = new Date(Math.max(...recentCheckIns.map(checkIn => new Date(checkIn.split(' - ')[1]).getTime())));
  const hasRecentCheckIn = new Date().getTime() - lastCheckIn.getTime() < 12 * 60 * 60 * 1000;

  const generateShareLink = () => {
    return `https://eldercare-mvp-2026.pages.dev/caregiver?checkIns=${encodeURIComponent(checkIns)}`;
  };

  function handleLogin(username, password) {
    if (username === 'caregiver' && password === 'password123') {
      setMode('caregiver');
      return true;
    } else {
      alert('Invalid credentials');
      return false;
    }
  }

  const styles = {
    container: {
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      height: '100vh',
      backgroundColor: '#f6c59d', // Sunset orange
    },
    redBanner: {
      backgroundColor: '#FF4136',
      padding: '0.5rem 1rem',
      borderRadius: '8px',
      fontSize: '24px',
      marginBottom: '1rem',
    },
  };

  return (
    <Router>
      <div style={styles.container}>
        {mode === 'caregiver' && setMode('elder')}
        <h2>{mode === 'elder' ? 'Elder Mode' : ''}</h2>
        <p id="clock" style={{ fontSize: '48px', marginBottom: '1rem', color: '#0047ab' }}>{currentTime}</p>
        {mode === 'caregiver' && !hasRecentCheckIn && (
          <div style={styles.redBanner}>No recent check-in</div>
        )}
        <Routes>
          <Route path='/' element={<Home />} />
          <Route path='/checkin' element={<CheckIn />} />
          <Route path='/history' element={<History />} />
          {mode === 'caregiver' && (
            <Route path='/caregiver' element={<CaregiverDashboard />} />
          )}
        </Routes>
      </div>
    </Router>
  );
}

function Home() {
  return <div style={styles.container}>Home</div>;
}

function CheckIn() {
  return <div style={styles.container}>Check-In</div>;
}

function History() {
  return <div style={styles.container}>History</div>;
}

function CaregiverDashboard() {
  const checkIns = localStorage.getItem('checkIn');
  const recentCheckIns = checkIns ? checkIns.split(',').slice(-5) : [];
  return (
    <div style={styles.container}>
      <h2>Recent Check-Ins</h2>
      {recentCheckIns.map((checkIn, index) => {
        const [type, time] = checkIn.split(' - ');
        return (
          <p key={index}>{time}: {type}</p>
        );
      })}
    </div>
  );
}

export default App;
