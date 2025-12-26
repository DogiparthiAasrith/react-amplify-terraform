import React from 'react';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>🚀 React + AWS Amplify</h1>
        <p>Deployed with Terraform & GitHub Actions</p>
        <div className="features">
          <div className="feature-card">
            <h3>⚡ Fast</h3>
            <p>Powered by AWS Amplify CDN</p>
          </div>
          <div className="feature-card">
            <h3>🔒 Secure</h3>
            <p>HTTPS enabled by default</p>
          </div>
          <div className="feature-card">
            <h3>🔄 CI/CD</h3>
            <p>Automated deployments</p>
          </div>
        </div>
      </header>
    </div>
  );
}

export default App;
