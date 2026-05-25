import React, { useState } from 'react';

const API_URL = 'http://localhost:3000';

export default function App() {
  const [target, setTarget] = useState('');
  const [amount, setAmount] = useState('');
  const [status, setStatus] = useState('Esperando transacción...');
  const [statusColor, setStatusColor] = useState('#f59e0b');
  const [intervalId, setIntervalId] = useState<number | null>(null);

  const enviarPago = async () => {
    if (!target || !amount) {
      setStatus('COMPLETA_LOS_CAMPOS');
      setStatusColor('#ef4444');
      return;
    }
    try {
      setStatus('PENDIENTE');
      setStatusColor('#f59e0b');

      const response = await fetch(`${API_URL}/api/transfer`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ target, amount })
      });

      if (!response.ok) {
        throw new Error(`Error HTTP ${response.status}`);
      }

      const data = await response.json();

      if (intervalId) clearInterval(intervalId);

      const poll = window.setInterval(async () => {
        try {
          const resStatus = await fetch(`${API_URL}/api/status/${data.id}`);
          const statusData = await resStatus.json();

          setStatus(statusData.status);

          if (statusData.status === 'APROBADO') {
            setStatusColor('#10b981');
            clearInterval(poll);
          } else if (statusData.status === 'ERROR_TIMEOUT') {
            setStatusColor('#ef4444');
            clearInterval(poll);
          } else {
            setStatusColor('#f59e0b');
          }
        } catch {
          setStatus('ERROR_CONSULTANDO_ESTADO');
          setStatusColor('#ef4444');
          clearInterval(poll);
        }
      }, 1000);

      setIntervalId(poll);
    } catch {
      setStatus('ERROR_ENVIANDO_TRANSFERENCIA');
      setStatusColor('#ef4444');
    }
  };

  return (
    <div style={{ background: '#0f172a', color: '#fff', minHeight: '100vh', fontFamily: 'sans-serif', textAlign: 'center', padding: 50 }}>
      <h1>Lite Bank - Portal de Pagos</h1>
      <div style={{ background: '#1e293b', padding: 30, borderRadius: 12, display: 'inline-block', border: '1px solid #334155' }}>
        <input type="text" placeholder="Cuenta Destino (Ej: 98765)" value={target} onChange={e => setTarget(e.target.value)} style={{ padding: 10, fontSize: 16, margin: 10, borderRadius: 6, border: 'none' }} />
        <input type="number" placeholder="Monto ($)" value={amount} onChange={e => setAmount(e.target.value)} style={{ padding: 10, fontSize: 16, margin: 10, borderRadius: 6, border: 'none' }} />
        <br />
        <button onClick={enviarPago} style={{ padding: 10, fontSize: 16, margin: 10, borderRadius: 6, border: 'none', background: '#ffd100', color: '#000', fontWeight: 'bold', cursor: 'pointer' }}>Enviar Transferencia</button>
        <div id="status-box" style={{ marginTop: 20, fontSize: 24, fontWeight: 'bold', color: statusColor }}>Estado: {status}</div>
      </div>
    </div>
  );
}
