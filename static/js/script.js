// Variables globales
let context = null;
let ggwave = null;
let parameters = null;
let instance = null;
let statusTimeout = null; // Variable para controlar el timeout del mensaje de estado
let audioGenerationInProgress = false; // Variable para controlar si se está generando audio
let analyser = null; // Analizador para la visualización del audio
let visualizerAnimationFrame = null; // Para controlar la animación del visualizador
let currentAudioSource = null; // Para mantener referencia a la fuente de audio actual
let aiResponseInProgress = false; // Variable para controlar si se está procesando una respuesta de IA

// Esperar a que el DOM esté completamente cargado
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded - Initializing ggwave');
    
    // Inicializar el tema
    initTheme();
    
    // Inicializar ggwave
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    window.OfflineAudioContext = window.OfflineAudioContext || window.webkitOfflineAudioContext;
    
    // Función para deshabilitar el botón
    function disableButton() {
        const translateBtn = document.getElementById('translateBtn');
        if (translateBtn) {
            translateBtn.disabled = true;
            translateBtn.setAttribute('disabled', 'disabled'); // Para mayor compatibilidad
            translateBtn.classList.add('disabled'); // Clase adicional para estilos
        }
    }
    
    // Función para habilitar el botón
    function enableButton() {
        const translateBtn = document.getElementById('translateBtn');
        if (translateBtn) {
            translateBtn.disabled = false;
            translateBtn.removeAttribute('disabled');
            translateBtn.classList.remove('disabled');
        }
    }
    
    // Función para inicializar el tema
    function initTheme() {
        const themeToggle = document.getElementById('themeToggle');
        if (!themeToggle) return;
        
        // Verificar si hay un tema guardado en localStorage
        const savedTheme = localStorage.getItem('theme');
        
        // Si hay un tema guardado, aplicarlo
        if (savedTheme === 'dark') {
            document.documentElement.setAttribute('data-theme', 'dark');
            themeToggle.checked = true;
        } else {
            document.documentElement.setAttribute('data-theme', 'light');
            themeToggle.checked = false;
        }
        
        // Añadir evento para cambiar el tema
        themeToggle.addEventListener('change', function() {
            if (this.checked) {
                document.documentElement.setAttribute('data-theme', 'dark');
                localStorage.setItem('theme', 'dark');
                console.log('Tema oscuro activado');
            } else {
                document.documentElement.setAttribute('data-theme', 'light');
                localStorage.setItem('theme', 'light');
                console.log('Tema claro activado');
            }
            
            // Actualizar el visualizador si está activo
            if (visualizerAnimationFrame) {
                // Cancelar la animación actual y reiniciarla para aplicar los nuevos colores
                cancelAnimationFrame(visualizerAnimationFrame);
                if (currentAudioSource) {
                    startVisualization(currentAudioSource);
                }
            }
        });
    }
    
    // Función para inicializar el analizador de audio
    function setupAnalyser() {
        if (!context) {
            context = new AudioContext({sampleRate: 48000});
        }
        
        // Crear el analizador si no existe
        if (!analyser) {
            analyser = context.createAnalyser();
            analyser.fftSize = 256; // Tamaño de la FFT (potencia de 2)
            analyser.connect(context.destination);
        }
        
        return analyser;
    }
    
    // Función para iniciar la visualización del audio
    function startVisualization(source) {
        const analyser = setupAnalyser();
        source.connect(analyser);
        
        const visualizerContainer = document.getElementById('audioVisualizer');
        const canvas = document.getElementById('visualizerCanvas');
        const canvasCtx = canvas.getContext('2d');
        
        // Mostrar el contenedor del visualizador
        visualizerContainer.style.display = 'block';
        
        // Ajustar el tamaño del canvas
        canvas.width = visualizerContainer.clientWidth;
        canvas.height = visualizerContainer.clientHeight;
        
        // Obtener los datos del analizador
        const bufferLength = analyser.frequencyBinCount;
        const dataArray = new Uint8Array(bufferLength);
        
        // Función para dibujar el espectro
        function drawSpectrum() {
            // Cancelar cualquier animación previa
            if (visualizerAnimationFrame) {
                cancelAnimationFrame(visualizerAnimationFrame);
            }
            
            visualizerAnimationFrame = requestAnimationFrame(drawSpectrum);
            
            // Obtener los datos de frecuencia
            analyser.getByteFrequencyData(dataArray);
            
            // Limpiar el canvas
            canvasCtx.clearRect(0, 0, canvas.width, canvas.height);
            
            // Dibujar las barras del espectro
            const barWidth = (canvas.width / bufferLength) * 2.5;
            let x = 0;
            
            // Obtener los colores del tema actual
            const isDarkTheme = document.documentElement.getAttribute('data-theme') === 'dark';
            
            // Crear un gradiente para las barras - usando variables CSS
            const gradient = canvasCtx.createLinearGradient(0, canvas.height, 0, 0);
            
            // Usar colores basados en el tema actual
            const baseColor = getComputedStyle(document.documentElement).getPropertyValue('--visualizer-color').trim();
            const brightColor = getComputedStyle(document.documentElement).getPropertyValue('--visualizer-color-bright').trim();
            const accentColor = getComputedStyle(document.documentElement).getPropertyValue('--visualizer-color-accent').trim();
            
            gradient.addColorStop(0, baseColor);
            gradient.addColorStop(0.5, brightColor);
            gradient.addColorStop(1, accentColor);
            
            for (let i = 0; i < bufferLength; i++) {
                const barHeight = (dataArray[i] / 255) * canvas.height;
                
                // Dibujar la barra con el gradiente
                canvasCtx.fillStyle = gradient;
                canvasCtx.fillRect(x, canvas.height - barHeight, barWidth, barHeight);
                
                // Añadir un borde sutil a las barras
                canvasCtx.strokeStyle = isDarkTheme ? 'rgba(255, 255, 255, 0.3)' : 'rgba(255, 255, 255, 0.5)';
                canvasCtx.lineWidth = 1;
                canvasCtx.strokeRect(x, canvas.height - barHeight, barWidth, barHeight);
                
                x += barWidth + 1;
            }
        }
        
        // Iniciar la animación
        drawSpectrum();
        
        // Devolver una función para detener la visualización
        return function stopVisualization() {
            if (visualizerAnimationFrame) {
                cancelAnimationFrame(visualizerAnimationFrame);
                visualizerAnimationFrame = null;
            }
            visualizerContainer.style.display = 'none';
        };
    }
    
    // Función para restablecer la interfaz después de la reproducción de audio
    function resetInterface() {
        // Mostrar mensaje de listo para convertir
        document.getElementById('status').textContent = 'Ready to convert text to audio';
        
        // Resetear el estado
        audioGenerationInProgress = false;
        
        // Habilitar el botón Send solo si no hay una respuesta de IA en progreso
        if (!aiResponseInProgress) {
            enableButton();
        }
        
        // Limpiar la referencia a la fuente de audio actual
        currentAudioSource = null;
    }

    // Función para generar audio a partir de texto usando ggwave
    function generateAudio(text, isAiResponse = false) {
        return new Promise((resolve, reject) => {
            try {
                // Inicializar el contexto de audio si no existe
                if (!context) {
                    context = new AudioContext({sampleRate: 48000});
                    
                    parameters = ggwave.getDefaultParameters();
                    parameters.sampleRateInp = context.sampleRate;
                    parameters.sampleRateOut = context.sampleRate;
                    instance = ggwave.init(parameters);
                }
                
                console.log(`Generating audio for ${isAiResponse ? 'AI response' : 'user message'}:`, text);
                
                // Generar el audio con ggwave
                let waveform;
                try {
                    // Intentar con TxProtocolId (como en el ejemplo)
                    waveform = ggwave.encode(instance, text, ggwave.TxProtocolId.GGWAVE_TX_PROTOCOL_AUDIBLE_FAST, 10);
                } catch (e) {
                    try {
                        // Intentar con ProtocolId (como en test.html)
                        waveform = ggwave.encode(instance, text, ggwave.ProtocolId.GGWAVE_PROTOCOL_AUDIBLE_FAST, 10);
                    } catch (e2) {
                        // Intentar con un valor numérico directo (1 = audible fast)
                        waveform = ggwave.encode(instance, text, 1, 10);
                    }
                }
                
                // Función auxiliar para convertir arrays
                function convertTypedArray(src, type) {
                    var buffer = new ArrayBuffer(src.byteLength);
                    var baseView = new src.constructor(buffer).set(src);
                    return new type(buffer);
                }
                
                // Crear buffer de audio
                var buf = convertTypedArray(waveform, Float32Array);
                var buffer = context.createBuffer(1, buf.length, context.sampleRate);
                buffer.getChannelData(0).set(buf);
                var source = context.createBufferSource();
                source.buffer = buffer;
                
                // Guardar referencia a la fuente de audio actual
                currentAudioSource = source;
                
                // Iniciar la visualización del audio
                const stopVisualization = startVisualization(source);
                
                // Conectar la fuente al destino
                source.connect(context.destination);
                
                // Mostrar mensaje de audio generado
                document.getElementById('status').textContent = `Audio successfully generated ${isAiResponse ? 'for AI response' : ''}`;
                
                // Detectar cuando termina la reproducción
                source.onended = function() {
                    console.log('Audio playback ended');
                    
                    // Detener la visualización
                    stopVisualization();
                    
                    // Resolver la promesa
                    resolve();
                    
                    // Si no es una respuesta de IA, restablecer la interfaz
                    if (!isAiResponse) {
                        resetInterface();
                    }
                };
                
                // Iniciar la reproducción
                source.start(0);
                
                console.log('Audio generated and played');
                
            } catch (error) {
                console.error('Error generating audio with ggwave:', error);
                console.error('Error details:', error.message);
                reject(error);
            }
        });
    }
    
    // Función para obtener respuesta de la IA
    async function getAIResponse(userMessage) {
        aiResponseInProgress = true; // Asegurarse de que se establezca al inicio
        disableButton(); // Mantener el botón deshabilitado
        
        try {
            document.getElementById('status').textContent = 'Requesting AI response...';
            console.log('Sending request to DeepSeek API...');
            
            // Mostrar el contenedor de respuesta
            const responseContainer = document.getElementById('aiResponseContainer');
            responseContainer.style.display = 'block';
            
            // Limpiar respuesta anterior y mostrar mensaje de espera
            const responseTextarea = document.getElementById('aiResponseText');
            responseTextarea.value = 'Waiting for AI response...';
            
            // Obtener la URL actual para el registro
            const currentUrl = window.location.href;
            console.log(`Current URL: ${currentUrl}`);
            
            // Usar la URL base para la solicitud API
            const apiUrl = (window.baseUrl || window.location.origin) + '/api/chat';
            console.log(`API URL: ${apiUrl}`);
            
            // Realizar la solicitud a la API
            console.log('Fetching from API endpoint...');
            const response = await fetch(apiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Origin': window.location.origin
                },
                body: JSON.stringify({ message: userMessage }),
                credentials: 'same-origin'
            });
            
            console.log('Response status:', response.status);
            console.log('Response headers:', [...response.headers.entries()]);
            
            const data = await response.json();
            console.log('Response data received:', data ? 'Data received successfully' : 'No data received');
            
            if (response.ok) {
                console.log('API response successful');
                // Actualizar el estado
                document.getElementById('status').textContent = 'AI response received, generating audio...';
                
                // Mantener el mensaje de espera mientras se genera el audio
                responseTextarea.value = 'Decoding AI response...';
                
                // Generar audio para la respuesta de la IA
                console.log('Generating audio for AI response...');
                await generateAudio(data.response, true);
                console.log('Audio generation for AI response completed');
                
                // Mostrar la respuesta en el textarea DESPUÉS de que el audio haya terminado
                responseTextarea.value = data.response;
                console.log('AI response displayed in textarea');
                
                // Restablecer la interfaz después de reproducir el audio de la respuesta
                aiResponseInProgress = false; // Marcar que ya no hay respuesta en progreso
                resetInterface();
                
            } else {
                console.error('API response error:', data.error || 'Unknown error');
                // Mostrar el error
                responseTextarea.value = `Error: ${data.error || 'Unknown error'}`;
                document.getElementById('status').textContent = 'Error getting AI response';
                aiResponseInProgress = false; // Marcar que ya no hay respuesta en progreso
                resetInterface();
            }
        } catch (error) {
            console.error('Error getting AI response:', error);
            console.error('Error details:', error.message, error.stack);
            document.getElementById('aiResponseText').value = `Error: ${error.message}`;
            document.getElementById('status').textContent = 'Error getting AI response';
            aiResponseInProgress = false; // Marcar que ya no hay respuesta en progreso
            resetInterface();
        }
    }
    
    // Verificar si ggwave_factory está disponible
    if (typeof ggwave_factory !== 'undefined') {
        // Inicializar ggwave
        ggwave_factory().then(function(obj) {
            ggwave = obj;
            document.getElementById('status').textContent = 'Ready to convert text to audio';
            console.log('ggwave initialized successfully');
            
            // Inicializar el contenedor de respuesta de la IA
            document.getElementById('aiResponseText').value = '';
        }).catch(function(error) {
            console.error('Error initializing ggwave:', error);
            document.getElementById('status').textContent = 'Error initializing audio components.';
        });
    } else {
        console.error('ggwave_factory library is not available');
        document.getElementById('status').textContent = 'Error: Could not load audio library.';
    }
    
    // Obtener referencia al botón
    const translateBtn = document.getElementById('translateBtn');
    
    // Verificar que el botón existe
    if (!translateBtn) {
        console.error('Translation button not found');
        return;
    }
    
    console.log('Translation button found, setting up click event');
    
    // Añadir evento click al botón
    translateBtn.addEventListener('click', async () => {
        console.log('Translate button clicked');
        
        // Evitar múltiples clics mientras se procesa
        if (audioGenerationInProgress || aiResponseInProgress) {
            console.log('Processing already in progress, ignoring click');
            return;
        }
        
        const text = document.getElementById('inputText').value;
        
        if (!text) {
            alert('Please enter some text to translate.');
            return;
        }
        
        // Marcar que estamos generando audio
        audioGenerationInProgress = true;
        aiResponseInProgress = true;
        
        // Deshabilitar el botón mientras se genera el audio
        disableButton();
        
        // Mostrar mensaje de generación inmediatamente
        document.getElementById('status').textContent = 'Generating audio...';
        
        // Verificar si ggwave está inicializado
        if (!ggwave) {
            console.error('ggwave is not initialized');
            useSimulationMode(text);
            return;
        }
        
        try {
            // Generar audio para el mensaje del usuario
            await generateAudio(text);
            
            // Obtener respuesta de la IA
            await getAIResponse(text);
            
        } catch (error) {
            console.error('Error in processing:', error);
            document.getElementById('status').textContent = 'Error processing request';
            resetInterface();
            aiResponseInProgress = false;
        }
    });
    
    // Función para usar el modo de simulación
    function useSimulationMode(text) {
        console.log('Using simulation mode for:', text);
        document.getElementById('status').textContent = 'Generating audio (simulation mode)...';
        
        // Deshabilitar el botón mientras se genera el audio
        disableButton();
        
        // Mostrar el contenedor de respuesta con mensaje de espera
        const responseContainer = document.getElementById('aiResponseContainer');
        responseContainer.style.display = 'block';
        document.getElementById('aiResponseText').value = 'Decoding AI response...';
        
        // Generar un patrón de sonido basado en el texto
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        
        // Crear un patrón de sonido basado en la longitud del texto
        const duration = Math.min(text.length * 0.1, 3); // Máximo 3 segundos
        
        // Crear un nodo de ganancia para controlar el volumen
        const gainNode = audioContext.createGain();
        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        
        // Configurar el analizador para el modo de simulación
        const analyser = audioContext.createAnalyser();
        analyser.fftSize = 256;
        gainNode.connect(analyser);
        analyser.connect(audioContext.destination);
        
        // Iniciar la visualización
        const stopVisualization = startVisualization({ connect: function() { return; } }); // Objeto dummy
        
        // Calcular el tiempo total de la simulación
        const totalDuration = Math.min(text.length * 0.1, 3); // Máximo 3 segundos
        
        // Mostrar mensaje de audio generado
        document.getElementById('status').textContent = 'Audio successfully generated (simulation)';
        
        // Generar un sonido "tipo módem" simulando GibberLink
        for (let i = 0; i < text.length; i++) {
            const charCode = text.charCodeAt(i);
            
            // Crear un oscilador para cada carácter
            const oscillator = audioContext.createOscillator();
            
            // Frecuencia basada en el código ASCII del carácter
            const baseFreq = 800 + (charCode % 1000);
            oscillator.type = 'sine';
            
            // Programar cambios de frecuencia para simular un sonido de módem
            const startTime = audioContext.currentTime + (i * duration / text.length);
            const endTime = startTime + (duration / text.length) * 0.8;
            
            oscillator.frequency.setValueAtTime(baseFreq, startTime);
            oscillator.frequency.linearRampToValueAtTime(baseFreq + 200, startTime + 0.05);
            oscillator.frequency.linearRampToValueAtTime(baseFreq - 100, endTime);
            
            oscillator.connect(gainNode);
            oscillator.start(startTime);
            oscillator.stop(endTime);
        }
        
        console.log('Simulation completed');
        
        // Programar la restauración de la interfaz después de que termine la simulación
        setTimeout(() => {
            // Detener la visualización
            stopVisualization();
            
            // Restablecer la interfaz
            resetInterface();
            
            // Simular respuesta de IA - mostrar después de que el audio haya terminado
            document.getElementById('aiResponseText').value = "This is a simulated AI response since ggwave is not available. In a real environment, this would be a response from the DeepSeek API.";
            
            // Marcar que ya no estamos procesando una respuesta de IA
            aiResponseInProgress = false;
            
        }, (totalDuration * 1000) + 500); // Convertir a milisegundos y añadir un pequeño margen
    }
    
    console.log('Script fully loaded');
}); 