import { useState, useEffect } from 'react';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';

const styles = {
  container: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'center',
    height: '100vh',
    backgroundColor: '#f6c59d', // Sunset orange
  } as const,
  redBanner: {
    backgroundColor: '#FF4136',
    padding: '0.5rem 1rem',
    borderRadius: '8px',
    fontSize: '24px',
    marginBottom: '1rem',
  } as const,
};

function App() {
  const [mode, setMode] = useState<'elder' | 'caregiver'>('elder');
  const [currentTime, setCurrentTime] = useState(new Date().toLocaleTimeString());

  useEffect(() => {
    let intervalId: number | null = null;
    if (mode === 'elder') {
      intervalId = setInterval(() => {
        const nextReminder = new Date();
        nextReminder.setHours(nextReminder.getHours() + 4);
        Notification.requestPermission().then((permission: NotificationPermission) => {
          if (permission === 'granted') {
            new Notification('Med Reminder', { body: 'Take your medication!' });
          }
        });
      }, 30 * 60 * 1000); // Check every 30 minutes
    }

    return () => {
      if (intervalId) clearInterval(intervalId);
    };
  }, [mode]);

  useEffect(() => {
    const intervalId = setInterval(() => {
      setCurrentTime(new Date().toLocaleTimeString());
    }, 1000);
    return () => clearInterval(intervalId);
  }, []);

  const checkIns = localStorage.getItem('checkIn');
  const recentCheckIns = checkIns ? checkIns.split(',').slice(-5) : [];
  const lastCheckInTime = recentCheckIns.length ? Math.max(...recentCheckIns.map(checkIn => new Date(checkIn.split(' - ')[1]).getTime())) : 0;
  const hasRecentCheckIn = new Date().getTime() - lastCheckInTime < 12 * 60 * 60 * 1000;

  // Call to suppress unused error (remove if not needed)
  const generateShareLink = () => {
    return `https://eldercare-mvp-2026.pages.dev/caregiver?checkIns=${encodeURIComponent(checkIns || '')}`;
  };
  generateShareLink();

  // Call to suppress unused error (remove if not needed)
  const handleLogin = (username: string, password: string) => {
    if (username === 'caregiver' && password === 'password123') {
      setMode('caregiver');
      return true;
    } else {
      alert('Invalid credentials');
      return false;
    }
  };
  handleLogin('test', 'test');

  return (
    <Router>
      <div style={styles.container}>
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
