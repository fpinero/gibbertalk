# DeepSeek api documentation

### Links to DeepSeek API documentation:

https://api-docs.deepseek.com/ <br>
https://api-docs.deepseek.com/api/deepseek-api

### usage (Dashboard):
https://platform.deepseek.com/usage

### Example initial API call in Python

```Python
# Please install OpenAI SDK first: `pip3 install openai`

from openai import OpenAI

client = OpenAI(api_key="<DeepSeek API Key>", base_url="https://api.deepseek.com")

response = client.chat.completions.create(
    model="deepseek-chat",
    messages=[
        {"role": "system", "content": "You are a helpful assistant"},
        {"role": "user", "content": "Hello"},
    ],
    stream=False
)

print(response.choices[0].message.content)
````

<br>

## Reseacrh DeepSeek API
Soporte de idioma: DeepSeek es un modelo multilingüe. Permite preguntas en español o inglés y genera la respuesta en el mismo idioma (ha sido utilizado para español sin problemas (DeepSeek | Deep Seek Ai Free Chat Online)). La versión web oficial afirma “Supports All Languages” (DeepSeek | Deep Seek Ai Free Chat Online), aunque la calidad fuera del inglés puede variar.


Integración en Python: Ofrece un endpoint REST compatible con el formato de la API de OpenAI (DeepSeek API Docs: Your First API Call). Esto significa que se puede usar el SDK de OpenAI en Python cambiando solo la URL/clave para apuntar a DeepSeek. También existen librerías y ejemplos oficiales en Python en su documentación.


Costo (por 1,000 / 1,000,000 tokens): Muy bajo costo por token. DeepSeek maneja precios separados para tokens de entrada (prompt) y salida. En tarifa estándar, aproximadamente $0.00027 por 1K tokens de entrada ($0.27 por 1M) y $0.00110 por 1K tokens de salida ($1.10 por 1M) (Models & Pricing | DeepSeek API Docs) usando el modelo de chat general. Sumando entrada+salida, ~$1.37 por 1M tokens en total (pico). Sin embargo, aprovecha descuentos: en horas valle los precios se reducen ~50-75%. Por ejemplo, con descuentos y caching activo, la tarifa efectiva puede bajar a ~$0.42 por 1M tokens (entrada+salida) (How is DeepSeek Better Than ChatGPT: Cost Comparison). Nota: DeepSeek no cobra mensualidad, solo por uso.


Planes gratuitos: La API en sí es de pago (prepago por tokens), pero ofrece incentivos iniciales. Al registrarse en la plataforma open.deepseek, suelen otorgar un saldo gratuito (“granted balance”) – por ejemplo, a inicios de 2025 se promocionaron 500,000 tokens gratis para probar la plataforma (Is Deepseek API Free? Access and Usage Guide). Además, DeepSeek es open-source, por lo que el modelo DeepSeek-V3 puede usarse sin costo desplegándolo uno mismo (How is DeepSeek Better Than ChatGPT: Cost Comparison). También existen terceras vías gratuitas: por ejemplo, OpenRouter ofreció acceso gratis al modelo DeepSeek-R1 durante su vista previa (DeepSeek R1 Is Now Available on Azure AI Foundry and GitHub | Hacker News). En resumen, sí hay opciones de uso sin costo para prototipos (ya sea vía créditos promocionales o plataformas comunitarias), aunque la API oficial después requiere recargas de saldo.


Latencia: DeepSeek está optimizado para respuestas rápidas en consultas básicas. La versión DeepSeek-V3 (8B parámetros) genera ~60 tokens/segundo (How is DeepSeek Better Than ChatGPT: Cost Comparison), lo que equivale a ~1-2 segundos por respuesta corta (100 tokens aprox.). Usuarios reportan que la velocidad suele ser buena, aunque modelos más grandes como R1 con razonamiento profundo pueden ser más lentos (e.g. casos aislados en Azure tardaron ~80s en preguntas complejas (DeepSeek R1 Is Now Available on Azure AI Foundry and GitHub | Hacker News)). En general, para usos típicos conversacionales, la latencia promedio es de pocos segundos o menos.


Facilidad de integración: Muy sencilla. Al ser compatible con la API de OpenAI, se puede integrar con Python usando librerías existentes (openai Python SDK) cambiando el endpoint (DeepSeek API Docs: Your First API Call). DeepSeek proporciona documentación clara, ejemplos y no requiere infraestructura propia. Solo se necesita obtener una API Key desde su plataforma y hacer las llamadas HTTP correspondientes.


Restricciones de uso y políticas: DeepSeek no impone límites estrictos de tasa por defecto – “does NOT constrain user’s rate limit” (Rate Limit - DeepSeek API Docs) – más allá de su capacidad. Esto significa que no hay un techo fijo de RPS, pero el usuario debe ser responsable: es recomendable implementar límites en la aplicación para evitar usos accidentales masivos. Al ser prepago, no hay riesgo de gastos sorpresivos más allá del saldo cargado. Sus términos de servicio prohíben usos ilegales o maliciosos (similar a otras APIs). El modelo en sí podría tener algunos filtros integrados (se ha mencionado cierta censura alineada con normas locales en la versión R1 (DeepSeek-R1: does it conform to OSAID? - Open Source AI)), pero en general no aplica una moderación tan estricta como OpenAI. Aun así, se aconseja monitorear el uso para evitar abusos (por ejemplo, limitar el max_tokens en cada consulta para que un prompt malformulado no genere respuestas excesivamente largas y costosas).