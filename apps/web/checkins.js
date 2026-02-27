// Check-in storage and management
const CHECKIN_KEY = 'eldercare_checkins';

function saveCheckin() {
  const checkins = JSON.parse(localStorage.getItem(CHECKIN_KEY) || '[]');
  const currentTimestamp = new Date().toISOString();
  if (checkins.length < 30) {
    checkins.push(currentTimestamp);
    localStorage.setItem(CHECKIN_KEY, JSON.stringify(checkins));
  }
}

export { saveCheckin }