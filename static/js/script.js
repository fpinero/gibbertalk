// Variables globales
let context = null;
let ggwave = null;
let parameters = null;
let instance = null;

// Esperar a que el DOM esté completamente cargado
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM cargado - Inicializando ggwave');
    
    // Inicializar ggwave
    window.AudioContext = window.AudioContext || window.webkitAudioContext;
    window.OfflineAudioContext = window.OfflineAudioContext || window.webkitOfflineAudioContext;
    
    // Verificar si ggwave_factory está disponible
    if (typeof ggwave_factory !== 'undefined') {
        // Inicializar ggwave
        ggwave_factory().then(function(obj) {
            ggwave = obj;
            document.getElementById('status').textContent = 'Listo para convertir texto a audio';
            console.log('ggwave inicializado correctamente');
        }).catch(function(error) {
            console.error('Error al inicializar ggwave:', error);
            document.getElementById('status').textContent = 'Error al inicializar componentes de audio.';
        });
    } else {
        console.error('La biblioteca ggwave_factory no está disponible');
        document.getElementById('status').textContent = 'Error: No se pudo cargar la biblioteca de audio.';
    }
    
    // Obtener referencia al botón
    const translateBtn = document.getElementById('translateBtn');
    
    // Verificar que el botón existe
    if (!translateBtn) {
        console.error('No se encontró el botón de traducción');
        return;
    }
    
    console.log('Botón de traducción encontrado, configurando evento click');
    
    // Añadir evento click al botón
    translateBtn.addEventListener('click', () => {
        console.log('Botón traducir pulsado');
        
        const text = document.getElementById('inputText').value;
        
        if (!text) {
            alert('Por favor, ingresa algún texto para traducir.');
            return;
        }
        
        // Verificar si ggwave está inicializado
        if (!ggwave) {
            console.error('ggwave no está inicializado');
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
            
            console.log('Generando audio para:', text);
            document.getElementById('status').textContent = 'Generando audio...';
            
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
            
            console.log('Audio generado y reproducido');
            document.getElementById('status').textContent = 'Audio generado correctamente';
            
        } catch (error) {
            console.error('Error al generar audio con ggwave:', error);
            console.error('Detalles del error:', error.message);
            useSimulationMode(text);
        }
    });
    
    // Función para usar el modo de simulación
    function useSimulationMode(text) {
        console.log('Usando modo de simulación para:', text);
        document.getElementById('status').textContent = 'Generando audio (modo simulación)...';
        
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
        
        console.log('Simulación completada');
        document.getElementById('status').textContent = 'Audio generado correctamente (simulación)';
    }
    
    console.log('Script cargado completamente');
}); 