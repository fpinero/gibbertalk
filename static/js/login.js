document.addEventListener('DOMContentLoaded', () => {
    console.log('Login page loaded');
    
    const loginBtn = document.getElementById('loginBtn');
    const passwordInput = document.getElementById('passwordInput');
    const errorMessage = document.getElementById('errorMessage');
    const successMessage = document.getElementById('successMessage');
    const loadingSpinner = document.getElementById('loadingSpinner');
    const loginIcon = document.getElementById('loginIcon');
    const btnText = document.querySelector('.btn-text');
    
    function showMessage(message, type) {
        if (type === 'error') {
            errorMessage.textContent = message;
            errorMessage.style.display = 'block';
            successMessage.style.display = 'none';
        } else if (type === 'success') {
            successMessage.textContent = message;
            successMessage.style.display = 'block';
            errorMessage.style.display = 'none';
        } else {
            errorMessage.style.display = 'none';
            successMessage.style.display = 'none';
        }
    }
    
    function setLoading(loading) {
        loginBtn.disabled = loading;
        if (loading) {
            loadingSpinner.style.display = 'block';
            loginIcon.style.display = 'none';
            btnText.textContent = 'Verifying...';
        } else {
            loadingSpinner.style.display = 'none';
            loginIcon.style.display = 'block';
            btnText.textContent = 'Login';
        }
    }
    
    async function login() {
        const password = passwordInput.value.trim();
        
        if (!password) {
            showMessage('Please enter a password.', 'error');
            return;
        }
        
        if (password.length !== 4) {
            showMessage('Password must be 4 characters.', 'error');
            return;
        }
        
        showMessage('', '');
        setLoading(true);
        
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
                showMessage('Login successful! Redirecting...', 'success');
                setTimeout(() => {
                    window.location.href = '/';
                }, 1000);
            } else {
                showMessage('Invalid password. Please try again.', 'error');
                passwordInput.value = '';
                passwordInput.focus();
            }
        } catch (error) {
            console.error('Login error:', error);
            showMessage('An error occurred. Please try again.', 'error');
        } finally {
            setLoading(false);
        }
    }
    
    loginBtn.addEventListener('click', login);
    
    passwordInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            e.preventDefault();
            login();
        }
    });
    
    passwordInput.addEventListener('input', () => {
        if (errorMessage.style.display === 'block') {
            showMessage('', '');
        }
    });
    
    passwordInput.focus();
});
