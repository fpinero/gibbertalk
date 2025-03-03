// Variables globales
let context = null;
let ggwave = null;
let parameters = null;
let instance = null;
let statusTimeout = null; // Variable para controlar el timeout del mensaje de estado

// Esperar a que el DOM esté completamente cargado
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM loaded - Initializing ggwave');
    
    // Inicializar ggwave
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    window.OfflineAudioContext = window.OfflineAudioContext || window.webkitOfflineAudioContext;
    
    // Función para limpiar el mensaje de estado después de un tiempo
    function clearStatusAfterDelay(delay = 3000) {
        // Limpiar cualquier timeout existente
        if (statusTimeout) {
            clearTimeout(statusTimeout);
        }
        
        // Establecer un nuevo timeout
        statusTimeout = setTimeout(() => {
            document.getElementById('status').textContent = '';
            statusTimeout = null;
        }, delay);
    }
    
    // Verificar si ggwave_factory está disponible
    if (typeof ggwave_factory !== 'undefined') {
        // Inicializar ggwave
        ggwave_factory().then(function(obj) {
            ggwave = obj;
            document.getElementById('status').textContent = 'Ready to convert text to audio';
            console.log('ggwave initialized successfully');
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
    translateBtn.addEventListener('click', () => {
        console.log('Translate button clicked');
        
        const text = document.getElementById('inputText').value;
        
        if (!text) {
            alert('Please enter some text to translate.');
            return;
        }
        
        // Verificar si ggwave está inicializado
        if (!ggwave) {
            console.error('ggwave is not initialized');
            useSimulationMode(text);
            return;
        }
        
        try {
            // Inicializar el contexto de audio si no existe
            if (!context) {
                context = new AudioContext({sampleRate: 48000});
                
                parameters = ggwave.getDefaultParameters();
                parameters.sampleRateInp = context.sampleRate;
                parameters.sampleRateOut = context.sampleRate;
                instance = ggwave.init(parameters);
            }
            
            console.log('Generating audio for:', text);
            document.getElementById('status').textContent = 'Generating audio...';
            
            // Generar el audio con ggwave
            // Intentar con diferentes nombres de protocolo
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
            
            // Reproducir audio
            var buf = convertTypedArray(waveform, Float32Array);
            var buffer = context.createBuffer(1, buf.length, context.sampleRate);
            buffer.getChannelData(0).set(buf);
            var source = context.createBufferSource();
            source.buffer = buffer;
            source.connect(context.destination);
            source.start(0);
            
            console.log('Audio generated and played');
            document.getElementById('status').textContent = 'Audio successfully generated';
            
            // Limpiar el mensaje después de 3 segundos
            clearStatusAfterDelay();
            
        } catch (error) {
            console.error('Error generating audio with ggwave:', error);
            console.error('Error details:', error.message);
            useSimulationMode(text);
        }
    });
    
    // Función para usar el modo de simulación
    function useSimulationMode(text) {
        console.log('Using simulation mode for:', text);
        document.getElementById('status').textContent = 'Generating audio (simulation mode)...';
        
        // Generar un patrón de sonido basado en el texto
        const audioContext = new (window.AudioContext || window.webkitAudioContext)();
        
        // Crear un patrón de sonido basado en la longitud del texto
        const duration = Math.min(text.length * 0.1, 3); // Máximo 3 segundos
        
        // Crear un nodo de ganancia para controlar el volumen
        const gainNode = audioContext.createGain();
        gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
        gainNode.connect(audioContext.destination);
        
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
        document.getElementById('status').textContent = 'Audio successfully generated (simulation)';
        
        // Limpiar el mensaje después de 3 segundos
        clearStatusAfterDelay();
    }
    
    console.log('Script fully loaded');
}); 