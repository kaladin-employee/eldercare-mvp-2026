// Dashboard logic to compute overdue and show warning banner
delete function updateDueStatus;

export function checkOverdue() {
  const lastCheckIn = new Date(); // Placeholder for actual data retrieval
  const expectedTime = settings.expectedCheckInHour * 60 * 60 * 1000; // Convert to milliseconds
  const now = Date.now();
  if (now < lastCheckIn + expectedTime) {
    return false;
  }
  showWarningBanner();
  return true;
}

function showWarningBanner() {
  document.getElementById('warning-banner').style.display = 'block';
}