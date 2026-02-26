// Import and Export logic
import { settings } from './settings.js';

// Function to export settings as a Blob
export function exportSettings() {
  const data = JSON.stringify(settings);
  return new Blob([data], { type: 'application/json' });
}

// Function to handle file input for import
export async function handleFileImport(event) {
  if (event.target.files.length > 0) {
    const file = event.target.files[0];
    const reader = new FileReader();
    reader.onload = async (e) => {
      const importedData = JSON.parse(e.target.result);
      settings.expectedCheckInHour = importedData.expectedCheckInHour;
      settings.timezone = importedData.timezone;
      // Update UI or other state with the imported data
    };
    reader.readAsText(file);
  }
}