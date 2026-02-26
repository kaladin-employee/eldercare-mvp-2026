const role = 'caregiver';
generatePairCode();
function generatePairCode() {
  const pairCode = Math.random().toString(36).substr(2, 7);
  localStorage.setItem('elderCareRole', role);
  localStorage.setItem('elderCarePairCode', pairCode);
  localStorage.setItem('elderCareProfile', JSON.stringify({}));
  document.getElementById('pair-code').innerText = `Pair Code: ${pairCode}`;
}
