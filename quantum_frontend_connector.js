// quantum_frontend_connector.js
class QuantumLearningConnector {
    constructor() {
        this.socket = io('http://localhost:5000');
        this.apiBase = 'http://localhost:5000/api';
        this.studentId = 'student_' + Math.random().toString(36).substr(2, 9);
        this.setupSocketListeners();
    }

    setupSocketListeners() {
        this.socket.on('connected', (data) => {
            console.log('🔌 Connected to backend:', data.message);
        });

        this.socket.on('adaptations_generated', (data) => {
            this.displayAdaptations(data.adaptations);
        });

        this.socket.on('quantum_collapsed', (data) => {
            this.handleQuantumCollapse(data.collapse_data);
        });
    }

    async detectEmotionsFromCamera() {
        try {
            // Get camera stream
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            const video = document.createElement('video');
            video.srcObject = stream;
            video.play();

            // Capture frame every 3 seconds
            setInterval(() => {
                this.captureAndAnalyzeFrame(video);
            }, 3000);

        } catch (error) {
            console.error('❌ Camera access denied:', error);
            this.simulateEmotionDetection();
        }
    }

    captureAndAnalyzeFrame(video) {
        const canvas = document.createElement('canvas');
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        
        const ctx = canvas.getContext('2d');
        ctx.drawImage(video, 0, 0);

        canvas.toBlob(async (blob) => {
            const formData = new FormData();
            formData.append('image', blob, 'frame.jpg');

            try {
                const response = await fetch(`${this.apiBase}/detect-emotion`, {
                    method: 'POST',
                    body: formData
                });

                const result = await response.json();
                if (result.success) {
                    this.updateEmotionDisplay(result.emotions);
                    this.socket.emit('emotion_update', {
                        emotions: result.emotions,
                        learning_state: this.getCurrentLearningState(),
                        student_id: this.studentId
                    });
                }
            } catch (error) {
                console.error('❌ Emotion detection failed:', error);
            }
        });
    }

    async updateQuantumState(interactionData) {
        try {
            const response = await fetch(`${this.apiBase}/quantum-update`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    student_id: this.studentId,
                    interaction_type: interactionData.type,
                    success_rate: interactionData.success,
                    engagement_level: interactionData.engagement,
                    emotions: this.getCurrentEmotions()
                })
            });

            const result = await response.json();
            if (result.success) {
                this.updateQuantumDisplay(result.quantum_state);
                
                if (result.quantum_state.collapsed) {
                    this.socket.emit('quantum_collapse', {
                        student_id: this.studentId,
                        quantum_state: result.quantum_state
                    });
                }
            }
        } catch (error) {
            console.error('❌ Quantum update failed:', error);
        }
    }

    async getAdaptations() {
        try {
            const response = await fetch(`${this.apiBase}/get-adaptations`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    emotions: this.getCurrentEmotions(),
                    learning_state: this.getCurrentLearningState(),
                    student_id: this.studentId
                })
            });

            const result = await response.json();
            if (result.success) {
                this.displayAdaptations(result.adaptations);
            }
        } catch (error) {
            console.error('❌ Failed to get adaptations:', error);
        }
    }

    // Integration with your existing HTML functions
    updateEmotionDisplay(emotions) {
        // Update your existing emotion bars
        Object.keys(emotions).forEach(emotion => {
            const percentage = Math.round(emotions[emotion] * 100);
            const bar = document.getElementById(emotion + 'Bar');
            if (bar) {
                bar.style.width = percentage + '%';
                bar.textContent = `${emotion.charAt(0).toUpperCase() + emotion.slice(1)}: ${percentage}%`;
            }
        });
        
        // Update learning state
        this.updateLearningState(emotions);
    }

    updateQuantumDisplay(quantumState) {
        const styles = ['visual', 'auditory', 'kinesthetic'];
        styles.forEach(style => {
            const percentage = Math.round(quantumState.learning_styles[style] * 100);
            const probBar = document.getElementById(style + 'Prob');
            const percentText = document.getElementById(style + 'Percent');
            
            if (probBar) probBar.style.width = percentage + '%';
            if (percentText) percentText.textContent = percentage + '%';
        });

        if (quantumState.collapsed) {
            document.getElementById('collapseEmoji').textContent = '⚡';
            document.getElementById('collapseStatus').textContent = 'COLLAPSED';
            document.getElementById('optimalStyle').textContent = 
                quantumState.optimal_style.charAt(0).toUpperCase() + quantumState.optimal_style.slice(1);
            document.getElementById('confidence').textContent = 
                Math.round(quantumState.confidence * 100) + '%';
        }
    }

    displayAdaptations(adaptations) {
        const container = document.getElementById('adaptationsList');
        
        adaptations.forEach((adaptation, index) => {
            setTimeout(() => {
                const item = document.createElement('div');
                item.className = 'adaptation-item';
                item.textContent = adaptation;
                container.appendChild(item);
                
                if (container.children.length > 8) {
                    container.removeChild(container.firstChild);
                }
            }, index * 300);
        });
    }

    getCurrentEmotions() {
        // Extract current emotions from your UI
        const emotions = {};
        ['happy', 'engaged', 'confused', 'frustrated', 'bored'].forEach(emotion => {
            const bar = document.getElementById(emotion + 'Bar');
            if (bar) {
                const percentage = parseFloat(bar.textContent.match(/\d+/)[0]) || 0;
                emotions[emotion] = percentage / 100;
            }
        });
        return emotions;
    }

    getCurrentLearningState() {
        const stateElement = document.getElementById('learningState');
        return stateElement ? stateElement.textContent : 'neutral';
    }

    // Enhanced simulation with backend integration
    async simulateInteractionWithBackend(scenarioType) {
        const scenarios = {
            confused: { type: 'visual_content', success: 0.4, engagement: 0.3 },
            engaged: { type: 'interactive_activity', success: 0.8, engagement: 0.9 },
            bored: { type: 'text_reading', success: 0.3, engagement: 0.2 },
            frustrated: { type: 'quiz_attempt', success: 0.2, engagement: 0.4 },
            optimal: { type: 'hands_on', success: 0.95, engagement: 0.9 }
        };

        const scenario = scenarios[scenarioType];
        if (scenario) {
            // Update quantum state with backend
            await this.updateQuantumState(scenario);
            
            // Get fresh adaptations
            await this.getAdaptations();
        }
    }
}

// Initialize connector when page loads
let quantumConnector;
window.addEventListener('load', () => {
    quantumConnector = new QuantumLearningConnector();
    
    // Start emotion detection
    quantumConnector.detectEmotionsFromCamera();
    
    // Override existing simulation functions to use backend
    window.simulateInteraction = (scenarioType) => {
        // Keep your existing frontend simulation
        simulateInteraction(scenarioType);
        
        // Also update backend
        quantumConnector.simulateInteractionWithBackend(scenarioType);
    };
});

simulateInteraction('confused')  // Now sends to AI backend too!
simulateInteraction('engaged')   // Gets real AI adaptations!
resetSystem() 