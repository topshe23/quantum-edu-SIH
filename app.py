from flask import Flask, request, jsonify, render_template_string
from flask_socketio import SocketIO, emit
from flask_cors import CORS
import cv2
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv2D, MaxPooling2D, Flatten, Dense, Dropout
import base64
import json
import sqlite3
import threading
import time
from datetime import datetime
import os
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.config['SECRET_KEY'] = 'quantum_learning_secret_key_2024'
socketio = SocketIO(app, cors_allowed_origins="*")
CORS(app)

class EmotionDetector:
    def __init__(self):
        self.model = None
        self.emotion_labels = ['happy', 'sad', 'angry', 'surprised', 'fearful', 'disgusted', 'neutral']
        self.learning_emotions = {
            'happy': 'engaged',
            'neutral': 'focused', 
            'surprised': 'curious',
            'sad': 'confused',
            'angry': 'frustrated',
            'fearful': 'overwhelmed',
            'disgusted': 'bored'
        }
        self.build_model()
    
    def build_model(self):
        """Build a simple CNN for emotion detection"""
        try:
            # Try to load pre-trained model
            self.model = tf.keras.models.load_model('emotion_model.h5')
            print("✅ Loaded pre-trained emotion model")
        except:
            # Build and train a basic model
            print("🔄 Building new emotion detection model...")
            self.model = Sequential([
                Conv2D(32, (3, 3), activation='relu', input_shape=(48, 48, 1)),
                Conv2D(64, (3, 3), activation='relu'),
                MaxPooling2D(2, 2),
                Conv2D(128, (3, 3), activation='relu'),
                Conv2D(128, (3, 3), activation='relu'),
                MaxPooling2D(2, 2),
                Flatten(),
                Dense(512, activation='relu'),
                Dropout(0.5),
                Dense(len(self.emotion_labels), activation='softmax')
            ])
            self.model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
            print("✅ Basic emotion model built (needs training with real data)")
    
    def preprocess_face(self, face_image):
        """Preprocess face image for emotion detection"""
        if face_image is None:
            return None
        
        # Convert to grayscale if needed
        if len(face_image.shape) == 3:
            face_image = cv2.cvtColor(face_image, cv2.COLOR_BGR2GRAY)
        
        # Resize to model input size
        face_image = cv2.resize(face_image, (48, 48))
        face_image = face_image.astype('float32') / 255.0
        face_image = np.expand_dims(face_image, axis=0)
        face_image = np.expand_dims(face_image, axis=3)
        
        return face_image
    
    def detect_emotions(self, face_image):
        """Detect emotions from face image"""
        try:
            processed_face = self.preprocess_face(face_image)
            if processed_face is None:
                return self.get_neutral_emotions()
            
            # Get emotion predictions
            predictions = self.model.predict(processed_face, verbose=0)
            emotion_scores = predictions[0]
            
            # Convert to learning-relevant emotions
            learning_emotions = {
                'happy': float(emotion_scores[0]),
                'engaged': float(emotion_scores[0] * 0.8 + emotion_scores[3] * 0.2),  # happy + surprised
                'confused': float(emotion_scores[1] * 0.6 + emotion_scores[4] * 0.4),  # sad + fearful
                'frustrated': float(emotion_scores[2]),  # angry
                'bored': float(emotion_scores[5])  # disgusted
            }
            
            return learning_emotions
            
        except Exception as e:
            print(f"❌ Emotion detection error: {e}")
            return self.get_neutral_emotions()
    
    def get_neutral_emotions(self):
        """Return neutral emotion state"""
        return {
            'happy': 0.2,
            'engaged': 0.3,
            'confused': 0.1,
            'frustrated': 0.1,
            'bored': 0.1
        }

class QuantumLearningSystem:
    def __init__(self):
        self.learning_styles = {
            'visual': 0.33,
            'auditory': 0.33,
            'kinesthetic': 0.34
        }
        self.collapsed = False
        self.optimal_style = None
        self.confidence = 0.0
        self.interactions = []
    
    def update_quantum_state(self, interaction_data):
        """Update learning style probabilities based on interaction"""
        interaction_type = interaction_data.get('type', 'unknown')
        success_rate = interaction_data.get('success', 0.5)
        engagement = interaction_data.get('engagement', 0.5)
        
        # Update probabilities based on interaction success
        if interaction_type in ['image_click', 'visual_content']:
            self.learning_styles['visual'] *= (1 + success_rate * 0.3)
        elif interaction_type in ['audio_played', 'voice_response']:
            self.learning_styles['auditory'] *= (1 + success_rate * 0.3)
        elif interaction_type in ['interactive_activity', 'hands_on']:
            self.learning_styles['kinesthetic'] *= (1 + success_rate * 0.3)
        
        # Normalize probabilities
        total = sum(self.learning_styles.values())
        for style in self.learning_styles:
            self.learning_styles[style] /= total
        
        # Check for quantum collapse
        max_prob = max(self.learning_styles.values())
        if max_prob > 0.65 and not self.collapsed:
            self.trigger_collapse()
        
        return self.learning_styles
    
    def trigger_collapse(self):
        """Trigger quantum collapse when optimal style is determined"""
        self.collapsed = True
        self.optimal_style = max(self.learning_styles.items(), key=lambda x: x[1])[0]
        self.confidence = self.learning_styles[self.optimal_style]
        
        print(f"🌟 QUANTUM COLLAPSE! Optimal style: {self.optimal_style} ({self.confidence:.2%} confidence)")
        return {
            'collapsed': True,
            'optimal_style': self.optimal_style,
            'confidence': self.confidence,
            'learning_styles': self.learning_styles
        }
    
    def get_state(self):
        """Get current quantum learning state"""
        return {
            'learning_styles': self.learning_styles,
            'collapsed': self.collapsed,
            'optimal_style': self.optimal_style,
            'confidence': self.confidence
        }

class AdaptiveContentGenerator:
    def __init__(self):
        self.punjabi_phrases = {
            'encouragement': [
                "ਤੁਸੀਂ ਬਹੁਤ ਚੰਗਾ ਕੰਮ ਕਰ ਰਹੇ ਹੋ! (You're doing great!)",
                "ਸ਼ਾਬਾਸ਼! (Well done!)",
                "ਤੁਸੀਂ ਇਹ ਕਰ ਸਕਦੇ ਹੋ! (You can do this!)"
            ],
            'explanations': [
                "ਸਮਝ ਗਏ? (Do you understand?)",
                "ਚਲੋ ਇਸਨੂੰ ਸਮਝਦੇ ਹਾਂ (Let's understand this)",
                "ਇਹ ਬਿਲਕੁਲ ਸਿੰਪਲ ਹੈ (This is very simple)"
            ]
        }
        
        self.rural_analogies = {
            'photosynthesis': "ਪੌਧਾ ਸੂਰਜ ਤੋਂ ਊਰਜਾ ਲੈਂਦਾ ਹੈ ਜਿਵੇਂ ਸਾਡੇ ਸੋਲਰ ਪੈਨਲ ਲੈਂਦੇ ਹਨ",
            'cell_division': "ਸੈੱਲ ਵੰਡਦੇ ਹਨ ਜਿਵੇਂ ਗਿੱਦੜ ਦੇ ਬੱਚੇ ਦੋ ਹੋ ਜਾਂਦੇ ਹਨ",
            'water_cycle': "ਪਾਣੀ ਚੱਕਰ ਜਿਵੇਂ ਸਾਡੀ ਟਿਊਬਵੈੱਲ ਤੋਂ ਖੇਤਾਂ ਵਿੱਚ ਜਾਂਦਾ ਹੈ"
        }
    
    def generate_adaptations(self, emotions, learning_state, quantum_state):
        """Generate AI adaptations based on current state"""
        adaptations = []
        
        # Emotion-based adaptations
        if emotions.get('frustrated', 0) > 0.6:
            adaptations.extend([
                "🎵 Switching to calmer, slower voice tone",
                f"😌 Providing encouragement: '{self.get_random_phrase('encouragement')}'",
                "⏰ Suggesting 2-minute mindful break"
            ])
        
        if emotions.get('bored', 0) > 0.6:
            adaptations.extend([
                "⚡ Increasing energy and adding gamification",
                "🎮 Launching interactive village farming simulation",
                "🏆 Adding achievement badges and leaderboard"
            ])
        
        if emotions.get('confused', 0) > 0.7:
            adaptations.extend([
                "🔄 Simplifying explanation with rural Punjab analogies",
                f"🗣️ Switching to step-by-step Punjabi explanation",
                "📱 Sending concept to phone for offline review"
            ])
        
        if emotions.get('engaged', 0) > 0.8:
            adaptations.extend([
                "🚀 Increasing difficulty - student ready for advanced concepts",
                "🎯 Preparing university-level content",
                "👨‍🎓 Connecting with mentorship program"
            ])
        
        # Learning state adaptations
        if learning_state == 'struggling':
            adaptations.append("📚 Providing peer learning connection with successful rural student")
        elif learning_state == 'disengaged':
            adaptations.append("🌟 Sharing local success story: 'Meet Simran from nearby village...'")
        
        # Quantum state adaptations
        if quantum_state.get('collapsed'):
            style = quantum_state.get('optimal_style')
            adaptations.extend([
                f"🎯 QUANTUM COLLAPSE: Optimal style is {style}",
                f"🚀 All future content will be {style}-optimized",
                f"📊 Confidence level: {quantum_state.get('confidence', 0):.0%} - System highly certain"
            ])
        
        return adaptations
    
    def get_random_phrase(self, category):
        """Get random phrase from category"""
        import random
        return random.choice(self.punjabi_phrases.get(category, ['Hello!']))

# Initialize global components
emotion_detector = EmotionDetector()
quantum_system = QuantumLearningSystem()
content_generator = AdaptiveContentGenerator()

# Database setup
def init_database():
    """Initialize SQLite database for storing learning data"""
    conn = sqlite3.connect('learning_data.db')
    cursor = conn.cursor()
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS student_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id TEXT,
            session_start DATETIME,
            session_end DATETIME,
            total_interactions INTEGER,
            success_rate REAL,
            engagement_score REAL,
            optimal_learning_style TEXT,
            emotions_data TEXT
        )
    ''')
    
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS interactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            student_id TEXT,
            timestamp DATETIME,
            interaction_type TEXT,
            success_rate REAL,
            engagement_level REAL,
            emotions TEXT,
            adaptations_triggered TEXT
        )
    ''')
    
    conn.commit()
    conn.close()
    print("✅ Database initialized")

# API Routes
@app.route('/')
def index():
    """Serve the main HTML interface"""
    try:
        with open('quantum_learning_platform.html', 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        return """
        <h1>Quantum Learning Platform Backend Running!</h1>
        <p>Place your HTML file as 'quantum_learning_platform.html' in the same directory.</p>
        <p>Backend is running on this port with the following endpoints:</p>
        <ul>
            <li>/api/detect-emotion (POST)</li>
            <li>/api/quantum-update (POST)</li>
            <li>/api/get-adaptations (POST)</li>
            <li>/api/student-analytics (GET)</li>
        </ul>
        """

@app.route('/api/detect-emotion', methods=['POST'])
def detect_emotion_endpoint():
    """Detect emotions from uploaded image"""
    try:
        if 'image' not in request.files:
            return jsonify({'error': 'No image provided'}), 400
        
        image_file = request.files['image']
        
        # Read and decode image
        image_data = image_file.read()
        nparr = np.frombuffer(image_data, np.uint8)
        image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        
        if image is None:
            return jsonify({'error': 'Invalid image format'}), 400
        
        # Detect face (simplified - in production use proper face detection)
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
        faces = face_cascade.detectMultiScale(gray, 1.1, 4)
        
        if len(faces) > 0:
            x, y, w, h = faces[0]
            face_roi = gray[y:y+h, x:x+w]
            emotions = emotion_detector.detect_emotions(face_roi)
        else:
            # No face detected, return neutral emotions
            emotions = emotion_detector.get_neutral_emotions()
        
        return jsonify({
            'success': True,
            'emotions': emotions,
            'face_detected': len(faces) > 0,
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        print(f"❌ Error in emotion detection: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/quantum-update', methods=['POST'])
def quantum_update_endpoint():
    """Update quantum learning state"""
    try:
        data = request.get_json()
        interaction_data = {
            'type': data.get('interaction_type', 'unknown'),
            'success': data.get('success_rate', 0.5),
            'engagement': data.get('engagement_level', 0.5)
        }
        
        # Update quantum state
        new_state = quantum_system.update_quantum_state(interaction_data)
        
        # Store interaction in database
        store_interaction(
            student_id=data.get('student_id', 'anonymous'),
            interaction_data=interaction_data,
            emotions=data.get('emotions', {}),
            adaptations=data.get('adaptations_triggered', [])
        )
        
        return jsonify({
            'success': True,
            'quantum_state': quantum_system.get_state(),
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        print(f"❌ Error in quantum update: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/get-adaptations', methods=['POST'])
def get_adaptations_endpoint():
    """Generate AI adaptations based on current state"""
    try:
        data = request.get_json()
        emotions = data.get('emotions', {})
        learning_state = data.get('learning_state', 'neutral')
        quantum_state = quantum_system.get_state()
        
        # Generate adaptations
        adaptations = content_generator.generate_adaptations(
            emotions, learning_state, quantum_state
        )
        
        return jsonify({
            'success': True,
            'adaptations': adaptations,
            'quantum_state': quantum_state,
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        print(f"❌ Error generating adaptations: {e}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/student-analytics/<student_id>')
def student_analytics_endpoint(student_id):
    """Get analytics for a specific student"""
    try:
        conn = sqlite3.connect('learning_data.db')
        cursor = conn.cursor()
        
        # Get recent interactions
        cursor.execute('''
            SELECT * FROM interactions 
            WHERE student_id = ? 
            ORDER BY timestamp DESC 
            LIMIT 50
        ''', (student_id,))
        
        interactions = cursor.fetchall()
        
        # Calculate analytics
        if interactions:
            success_rates = [row[4] for row in interactions if row[4] is not None]
            engagement_levels = [row[5] for row in interactions if row[5] is not None]
            
            analytics = {
                'total_interactions': len(interactions),
                'avg_success_rate': sum(success_rates) / len(success_rates) if success_rates else 0,
                'avg_engagement': sum(engagement_levels) / len(engagement_levels) if engagement_levels else 0,
                'quantum_state': quantum_system.get_state(),
                'recent_interactions': interactions[:10]  # Last 10 interactions
            }
        else:
            analytics = {
                'total_interactions': 0,
                'avg_success_rate': 0,
                'avg_engagement': 0,
                'quantum_state': quantum_system.get_state(),
                'recent_interactions': []
            }
        
        conn.close()
        
        return jsonify({
            'success': True,
            'analytics': analytics,
            'timestamp': datetime.now().isoformat()
        })
    
    except Exception as e:
        print(f"❌ Error getting analytics: {e}")
        return jsonify({'error': str(e)}), 500

# WebSocket events for real-time communication
@socketio.on('connect')
def handle_connect():
    print('🔌 Client connected')
    emit('connected', {'message': 'Connected to Quantum Learning Platform'})

@socketio.on('disconnect')
def handle_disconnect():
    print('🔌 Client disconnected')

@socketio.on('emotion_update')
def handle_emotion_update(data):
    """Handle real-time emotion updates"""
    try:
        # Process emotions and generate adaptations
        emotions = data.get('emotions', {})
        learning_state = data.get('learning_state', 'neutral')
        
        adaptations = content_generator.generate_adaptations(
            emotions, learning_state, quantum_system.get_state()
        )
        
        # Broadcast adaptations to all connected clients
        emit('adaptations_generated', {
            'adaptations': adaptations,
            'timestamp': datetime.now().isoformat()
        }, broadcast=True)
        
    except Exception as e:
        print(f"❌ Error in emotion update: {e}")
        emit('error', {'message': str(e)})

@socketio.on('quantum_collapse')
def handle_quantum_collapse(data):
    """Handle quantum collapse events"""
    try:
        collapse_data = quantum_system.trigger_collapse()
        
        # Broadcast collapse event
        emit('quantum_collapsed', {
            'collapse_data': collapse_data,
            'timestamp': datetime.now().isoformat()
        }, broadcast=True)
        
    except Exception as e:
        print(f"❌ Error in quantum collapse: {e}")
        emit('error', {'message': str(e)})

# Helper functions
def store_interaction(student_id, interaction_data, emotions, adaptations):
    """Store interaction data in database"""
    try:
        conn = sqlite3.connect('learning_data.db')
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO interactions 
            (student_id, timestamp, interaction_type, success_rate, engagement_level, emotions, adaptations_triggered)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            student_id,
            datetime.now(),
            interaction_data.get('type'),
            interaction_data.get('success'),
            interaction_data.get('engagement'),
            json.dumps(emotions),
            json.dumps(adaptations)
        ))
        
        conn.commit()
        conn.close()
        
    except Exception as e:
        print(f"❌ Error storing interaction: {e}")

# Background tasks
def background_analytics_processor():
    """Background task to process analytics"""
    while True:
        try:
            # Process analytics, generate insights, etc.
            time.sleep(30)  # Run every 30 seconds
            
            # Example: Check for students who might need intervention
            conn = sqlite3.connect('learning_data.db')
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT student_id, AVG(success_rate), AVG(engagement_level)
                FROM interactions 
                WHERE timestamp > datetime('now', '-1 hour')
                GROUP BY student_id
                HAVING AVG(success_rate) < 0.3 OR AVG(engagement_level) < 0.3
            ''')
            
            struggling_students = cursor.fetchall()
            
            if struggling_students:
                print(f"⚠️ {len(struggling_students)} students may need intervention")
                # Here you could trigger alerts, notifications, etc.
            
            conn.close()
            
        except Exception as e:
            print(f"❌ Error in background analytics: {e}")
            time.sleep(60)  # Wait longer if there's an error

if __name__ == '__main__':
    print("🚀 Starting Quantum Learning Platform Backend...")
    
    # Initialize database
    init_database()
    
    # Start background tasks
    analytics_thread = threading.Thread(target=background_analytics_processor, daemon=True)
    analytics_thread.start()
    
    print("✅ Backend initialization complete!")
    print("📡 Server starting on http://localhost:5000")
    print("🔌 WebSocket server ready for real-time communication")
    print("📊 Analytics processor running in background")
    
    # Run the Flask-SocketIO app
    socketio.run(app, host='0.0.0.0', port=5000, debug=True)
    
    import os

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))  # Render gives you the PORT
    app.run(host="0.0.0.0", port=port)
