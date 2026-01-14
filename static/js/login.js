document.addEventListener('DOMContentLoaded', () => {
    console.log('Matrix login page loaded');
    
    const passwordInput = document.getElementById('passwordInput');
    const statusMessage = document.getElementById('statusMessage');
    
    function showStatus(message, type) {
        statusMessage.textContent = message;
        statusMessage.className = 'status-message ' + type;
        
        if (type === 'error') {
            setTimeout(() => {
                passwordInput.value = '';
                passwordInput.focus();
            }, 1500);
        }
    }
    
    async function login() {
        const password = passwordInput.value.trim();
        
        if (!password) {
            return;
        }
        
        if (password.length !== 4) {
            showStatus('Invalid access', 'error');
            return;
        }
        
        showStatus('Authenticating...', 'success');
        
        try {
            const response = await fetch('/api/verify-password', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ password: password })
            });
            
            const data = await response.json();
            
            if (response.ok && data.success) {
                showStatus('Access granted', 'success');
                setTimeout(() => {
                    window.location.href = '/';
                }, 500);
            } else {
                showStatus('Access denied', 'error');
            }
        } catch (error) {
            console.error('Login error:', error);
            showStatus('System error', 'error');
        }
    }
    
    passwordInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            login();
        }
    });
    
    passwordInput.addEventListener('input', () => {
        if (statusMessage.className.includes('error')) {
            statusMessage.textContent = '';
            statusMessage.className = 'status-message';
        }
    });
    
    passwordInput.focus();
    
    const canvas = document.getElementById('matrixCanvas');
    const ctx = canvas.getContext('2d');
    
    function resizeCanvas() {
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    }
    
    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);
    
    const columns = Math.floor(canvas.width / 20);
    const drops = [];
    for (let i = 0; i < columns; i++) {
        drops[i] = Math.random() * -100;
    }
    
    function drawMatrix() {
        ctx.fillStyle = 'rgba(0, 0, 0, 0.05)';
        ctx.fillRect(0, 0, canvas.width, canvas.height);
        
        ctx.fillStyle = '#00ff00';
        ctx.font = '15px monospace';
        
        for (let i = 0; i < drops.length; i++) {
            const text = String.fromCharCode(0x30A0 + Math.random() * 96);
            ctx.fillText(text, i * 20, drops[i]);
            
            if (drops[i] > canvas.height && Math.random() > 0.975) {
                drops[i] = 0;
            }
            drops[i]++;
        }
    }
    
    setInterval(drawMatrix, 50);
});