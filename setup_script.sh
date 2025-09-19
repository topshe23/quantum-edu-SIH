/**
 * Quantum Learning Platform - Frontend-Backend Connector
 * Connects your HTML interface with the Python backend
 */

class QuantumLearningConnector {
    constructor() {
        this.socket = io('http://localhost:5000');
        this.apiBase = 'http://localhost:5000/api';
        this.studentId = 'student_' + Math.random().toString(36).substr(2, 9);
        this.emotionDetectionInterval = null;
        this.cameraStream = null;
        
        console.log('🧠 Quantum Learning Connector initialized for student:', this.studentId);
        this.setupSocketListeners();
        this.initializeRealTimeFeatures();
    }

    setupSocketListeners() {
        this.socket.on('connected', (data) => {
            console.log('🔌 Connected to backend:', data.message);
            this.showNotification('Connected to AI Backend!', 'success');
        });

        this.socket.on('adaptations_generated', (data) => {
            console.log('🤖 New adaptations received:', data.adaptations);
            this.displayAdaptations(data.adaptations);
        });

        this.socket.on('quantum_collapsed', (data) => {
            console.log('⚡ Quantum collapse detected!', data.collapse_data);
            this.handleQuantumCollapse(data.collapse_data);
        });

        this.socket.on('error', (data) => {
            console.error('❌ Backend error:', data.message);
            this.showNotification('Backend Error: ' + data.message, 'error');
        });

        this.socket.on('disconnect', () => {
            console.log('🔌 Disconnected from backend');
            this.showNotification('Disconnected from backend', 'warning');
        });
    }

    async initializeRealTimeFeatures() {
        // Initialize real-time emotion detection
        await this.initializeCameraDetection();
        
        // Start periodic analytics updates
        this.startAnalyticsUpdates();
        
        // Add enhanced interaction tracking
        this.setupInteractionTracking();
    }

    async initializeCameraDetection() {
        try {
            console.log('📹 Initializing camera for emotion detection...');
            
            // Request camera permission
            this.cameraStream = await navigator.mediaDevices.getUserMedia({ 
                video: { 
                    width: { ideal: 640 },
                    height: { ideal: 480 },
                    facingMode: 'user'
                }
            });

            // Update camera feed display
            const cameraFeed = document.getElementById('cameraFeed');
            if (cameraFeed) {
                cameraFeed.innerHTML = '';
                const video = document.createElement('video');
                video.srcObject = this.cameraStream;
                video.autoplay = true;
                video.muted = true;
                video.style.width = '100%';
                video.style.height = '100%';
                video.style.objectFit = 'cover';
                video.style.borderRadius = '10px';
                cameraFeed.appendChild(video);

                // Start emotion detection from camera
                video.onloadedmetadata = () => {
                    this.startEmotionDetection(video);
                };
            }

            this.showNotification('Camera initialized for emotion detection!', 'success');

        } catch (error) {
            console.warn('📹 Camera access denied, using simulation mode:', error);
            this.showNotification('Camera access denied - using simulation mode', 'info');
            this.simulateEmotionDetection();
        }
    }

    startEmotionDetection(video) {
        // Capture and analyze frames every 3 seconds
        this.emotionDetectionInterval = setInterval(() => {
            this.captureAndAnalyzeFrame(video);
        }, 3000);

        console.log('🎭 Real-time emotion detection started');
    }

    captureAndAnalyzeFrame(video) {
        try {
            const canvas = document.createElement('canvas');
            canvas.width = video.videoWidth || 640;
            canvas.height = video.videoHeight || 480;
            
            const ctx = canvas.getContext('2d');
            ctx.drawImage(video, 0, 0);

            // Convert canvas to blob and send to backend
            canvas.toBlob(async (blob) => {
                if (blob) {
                    await this.analyzeEmotionFromImage(blob);
                }
            }, 'image/jpeg', 0.8);

        } catch (error) {
            console.error('❌ Frame capture error:', error);
        }
    }

    async analyzeEmotionFromImage(imageBlob) {
        try {
            const formData = new FormData();
            formData.append('image', imageBlob, 'frame.jpg');

            const response = await fetch(`${this.apiBase}/detect-emotion`, {
                method: 'POST',
                body: formData
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const result = await response.json();
            
            if (result.success) {
                // Update emotion display
                this.updateEmotionDisplay(result.emotions);
                
                // Emit emotion update via WebSocket
                this.socket.emit('emotion_update', {
                    emotions: result.emotions,
                    learning_state: this.getCurrentLearningState(),
                    student_id: this.studentId,
                    timestamp: new Date().toISOString(),
                    face_detected: result.face_detected
                });

                console.log('🎭 Emotions detected:', result.emotions);

            } else {
                console.warn('⚠️ Emotion detection failed:', result.error);
            }

        } catch (error) {
            console.error('❌ Emotion analysis failed:', error);
            // Fallback to neutral emotions if detection fails
            this.updateEmotionDisplay(this.getNeutralEmotions());
        }
    }

    simulateEmotionDetection() {
        // Fallback simulation when camera is not available
        console.log('🎭 Starting emotion simulation mode');
        
        setInterval(() => {
            const simulatedEmotions = this.generateSimulatedEmotions();
            this.updateEmotionDisplay(simulatedEmotions);
            
            this.socket.emit('emotion_update', {
                emotions: simulatedEmotions,
                learning_state: this.getCurrentLearningState(),
                student_id: this.studentId,
                simulated: true
            });
        }, 5000);
    }

    generateSimulatedEmotions() {
        // Generate realistic emotional fluctuations
        const base = {
            happy: 0.3 + Math.random() * 0.4,
            engaged: 0.4 + Math.random() * 0.5,
            confused: 0.1 + Math.random() * 0.3,
            frustrated: 0.05 + Math.random() * 0.2,
            bored: 0.1 + Math.random() * 0.3
        };
        
        // Normalize to ensure they make sense together
        const total = Object.values(base).reduce((sum, val) => sum + val, 0);
        Object.keys(base).forEach(key => {
            base[key] = Math.min(base[key] / total * 2, 1.0);
        });
        
        return base;
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
                    emotions: this.getCurrentEmotions(),
                    timestamp: new Date().toISOString()
                })
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const result = await response.json();
            
            if (result.success) {
                // Update quantum display
                this.updateQuantumDisplay(result.quantum_state);
                
                // Check for quantum collapse
                if (result.quantum_state.collapsed && !this.quantumCollapsed) {
                    this.quantumCollapsed = true;
                    this.socket.emit('quantum_collapse', {
                        student_id: this.studentId,
                        quantum_state: result.quantum_state
                    });
                }

                console.log('🔮 Quantum state updated:', result.quantum_state);
                return result.quantum_state;

            } else {
                throw new Error(result.error || 'Quantum update failed');
            }

        } catch (error) {
            console.error('❌ Quantum update failed:', error);
            this.showNotification('Quantum update failed: ' + error.message, 'error');
            return null;
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
                    student_id: this.studentId,
                    timestamp: new Date().toISOString()
                })
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const result = await response.json();
            
            if (result.success) {
                this.displayAdaptations(result.adaptations);
                console.log('🤖 Adaptations received:', result.adaptations);
                return result.adaptations;
            } else {
                throw new Error(result.error || 'Failed to get adaptations');
            }

        } catch (error) {
            console.error('❌ Failed to get adaptations:', error);
            this.showNotification('Failed to get AI adaptations', 'error');
            return [];
        }
    }

    async getStudentAnalytics() {
        try {
            const response = await fetch(`${this.apiBase}/student-analytics/${this.studentId}`);
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            const result = await response.json();
            
            if (result.success) {
                this.updateAnalyticsDisplay(result.analytics);
                return result.analytics;
            } else {
                throw new Error(result.error || 'Failed to get analytics');
            }

        } catch (error) {
            console.error('❌ Failed to get analytics:', error);
            return null;
        }
    }

    // UI Update Methods
    updateEmotionDisplay(emotions) {
        Object.keys(emotions).forEach(emotion => {
            const percentage = Math.round(emotions[emotion] * 100);
            const bar = document.getElementById(emotion + 'Bar');
            if (bar) {
                bar.style.width = percentage + '%';
                bar.textContent = `${emotion.charAt(0).toUpperCase() + emotion.slice(1)}: ${percentage}%`;
                
                // Add visual feedback based on emotion levels
                if (percentage > 70) {
                    bar.style.background = 'linear-gradient(90deg, #4ECDC4, #44A08D)';
                } else if (percentage > 40) {
                    bar.style.background = 'linear-gradient(90deg, #4facfe, #00f2fe)';
                } else {
                    bar.style.background = 'linear-gradient(90deg, #667eea, #764ba2)';
                }
            }
        });
        
        this.updateLearningStateIndicator(emotions);
    }

    updateLearningStateIndicator(emotions) {
        const indicator = document.getElementById('statusIndicator');
        const stateText = document.getElementById('learningState');
        
        if (!indicator || !stateText) return;
        
        let newState = 'neutral';
        let indicatorClass = 'status-indicator';
        
        if (emotions.engaged > 0.6 && emotions.happy > 0.3) {
            newState = 'optimal';
            indicatorClass = 'status-indicator status-optimal';
        } else if (emotions.confused > 0.5 || emotions.frustrated > 0.4) {
            newState = 'struggling';
            indicatorClass = 'status-indicator status-struggling';
        } else if (emotions.bored > 0.6) {
            newState = 'disengaged';
            indicatorClass = 'status-indicator status-disengaged';
        } else if (emotions.frustrated > 0.7) {
            newState = 'overwhelmed';
            indicatorClass = 'status-indicator status-overwhelmed';
        }
        
        indicator.className = indicatorClass;
        stateText.textContent = newState.charAt(0).toUpperCase() + newState.slice(1);
    }

    updateQuantumDisplay(quantumState) {
        const styles = ['visual', 'auditory', 'kinesthetic'];
        
        styles.forEach(style => {
            const percentage = Math.round(quantumState.learning_styles[style] * 100);
            const probBar = document.getElementById(style + 'Prob');
            const percentText = document.getElementById(style + 'Percent');
            
            if (probBar) {
                probBar.style.width = percentage + '%';
                // Add glow effect for dominant style
                if (percentage > 50) {
                    probBar.style.boxShadow = '0 0 10px rgba(255, 215, 0, 0.6)';
                } else {
                    probBar.style.boxShadow = 'none';
                }
            }
            if (percentText) percentText.textContent = percentage + '%';
        });

        // Update collapse status
        if (quantumState.collapsed) {
            document.getElementById('collapseEmoji').textContent = '⚡';
            document.getElementById('collapseStatus').textContent = 'COLLAPSED';
            document.getElementById('optimalStyle').textContent = 
                quantumState.optimal_style.charAt(0).toUpperCase() + quantumState.optimal_style.slice(1);
            document.getElementById('confidence').textContent = 
                Math.round(quantumState.confidence * 100) + '%';
                
            // Show collapse alert
            this.showQuantumCollapseAlert(quantumState);
        }
    }

    showQuantumCollapseAlert(quantumState) {
        const alert = document.getElementById('collapseAlert');
        if (alert) {
            alert.innerHTML = `
                <div class="collapse-alert">
                    ⚡ QUANTUM COLLAPSE OCCURRED! ⚡<br>
                    🎯 Optimal Learning Style: <strong>${quantumState.optimal_style.toUpperCase()}</strong><br>
                    📊 Confidence Level: <strong>${Math.round(quantumState.confidence * 100)}%</strong><br>
                    🚀 Personalizing all future content for maximum effectiveness!
                </div>
            `;
            alert.style.display = 'block';
        }
        
        // Auto-hide after 10 seconds
        setTimeout(() => {
            if (alert) alert.style.display = 'none';
        }, 10000);
    }

    displayAdaptations(adaptations) {
        const container = document.getElementById('adaptationsList');
        if (!container) return;
        
        adaptations.forEach((adaptation, index) => {
            setTimeout(() => {
                const item = document.createElement('div');
                item.className = 'adaptation-item';
                item.innerHTML = `
                    <span class="adaptation-text">${adaptation}</span>
                    <span class="adaptation-time">${new Date().toLocaleTimeString()}</span>
                `;
                container.appendChild(item);
                
                // Keep only recent adaptations
                if (container.children.length > 8) {
                    container.removeChild(container.firstChild);
                }

                // Scroll to show latest adaptation
                container.scrollTop = container.scrollHeight;
                
            }, index * 300);
        });
    }

    updateAnalyticsDisplay(analytics) {
        // Update success rate
        const successRate = document.getElementById('successRate');
        if (successRate) {
            successRate.textContent = Math.round(analytics.avg_success_rate * 100) + '%';
        }
        
        // Update engagement score
        const engagementScore = document.getElementById('engagementScore');
        if (engagementScore) {
            engagementScore.textContent = Math.round(analytics.avg_engagement * 100) + '%';
        }
        
        // Update progress circle
        const progressCircle = document.getElementById('progressCircle');
        if (progressCircle) {
            const percentage = analytics.avg_success_rate * 100;
            const circumference = 2 * Math.PI * 54;
            const offset = circumference - (percentage / 100) * circumference;
            progressCircle.style.strokeDashoffset = offset;
        }
    }

    // Enhanced Simulation Methods
    async simulateInteractionWithBackend(scenarioType) {
        const scenarios = {
            confused: { 
                type: 'visual_content', 
                success: 0.4, 
                engagement: 0.3,
                description: 'Student viewing confusing diagram'
            },
            engaged: { 
                type: 'interactive_activity', 
                success: 0.8, 
                engagement: 0.9,
                description: 'Student actively participating in simulation'
            },
            bored: { 
                type: 'text_reading', 
                success: 0.3, 
                engagement: 0.2,
                description: 'Student reading lengthy text content'
            },
            frustrated: { 
                type: 'quiz_attempt', 
                success: 0.2, 
                engagement: 0.4,
                description: 'Student failing repeated quiz attempts'
            },
            optimal: { 
                type: 'hands_on_activity', 
                success: 0.95, 
                engagement: 0.9,
                description: 'Student in optimal flow state'
            }
        };

        const scenario = scenarios[scenarioType];
        if (!scenario) return;

        console.log(`🎮 Simulating: ${scenario.description}`);

        try {
            // Update quantum state
            await this.updateQuantumState(scenario);
            
            // Get fresh adaptations
            await this.getAdaptations();
            
            // Update analytics
            await this.getStudentAnalytics();
            
            this.showNotification(`Simulated: ${scenario.description}`, 'info');
            
        } catch (error) {
            console.error('❌ Backend simulation failed:', error);
            this.showNotification('Simulation failed: ' + error.message, 'error');
        }
    }

    // Utility Methods
    getCurrentEmotions() {
        const emotions = {};
        ['happy', 'engaged', 'confused', 'frustrated', 'bored'].forEach(emotion => {
            const bar = document.getElementById(emotion + 'Bar');
            if (bar) {
                const text = bar.textContent;
                const match = text.match(/(\d+)%/);
                const percentage = match ? parseFloat(match[1]) : 0;
                emotions[emotion] = percentage / 100;
            } else {
                emotions[emotion] = 0;
            }
        });
        return emotions;
    }

    getCurrentLearningState() {
        const stateElement = document.getElementById('learningState');
        return stateElement ? stateElement.textContent.toLowerCase() : 'neutral';
    }

    getNeutralEmotions() {
        return {
            happy: 0.2,
            engaged: 0.3,
            confused: 0.1,
            frustrated: 0.1,
            bored: 0.1
        };
    }

    setupInteractionTracking() {
        // Track all user interactions on the page
        const trackableElements = [
            'sim-button',
            'card',
            'emotion-bar',
            'probability-bar'
        ];

        trackableElements.forEach(className => {
            const elements = document.getElementsByClassName(className);
            Array.from(elements).forEach(element => {
                element.addEventListener('click', (event) => {
                    this.trackInteraction({
                        type: 'click',
                        element: className,
                        timestamp: new Date().toISOString(),
                        position: { x: event.clientX, y: event.clientY }
                    });
                });
            });
        });

        // Track page focus/blur for engagement
        window.addEventListener('focus', () => {
            this.trackInteraction({ type: 'page_focus', timestamp: new Date().toISOString() });
        });

        window.addEventListener('blur', () => {
            this.trackInteraction({ type: 'page_blur', timestamp: new Date().toISOString() });
        });
    }

    trackInteraction(interactionData) {
        // Send interaction data to backend for analysis
        this.socket.emit('interaction_tracked', {
            student_id: this.studentId,
            interaction: interactionData,
            current_emotions: this.getCurrentEmotions(),
            learning_state: this.getCurrentLearningState()
        });
    }

    startAnalyticsUpdates() {
        // Update analytics every 30 seconds
        setInterval(async () => {
            await this.getStudentAnalytics();
        }, 30000);
    }

    showNotification(message, type = 'info') {
        // Create notification element if it doesn't exist
        let notificationContainer = document.getElementById('notificationContainer');
        if (!notificationContainer) {
            notificationContainer = document.createElement('div');
            notificationContainer.id = 'notificationContainer';
            notificationContainer.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
                pointer-events: none;
            `;
            document.body.appendChild(notificationContainer);
        }

        // Create notification
        const notification = document.createElement('div');
        notification.style.cssText = `
            background: ${this.getNotificationColor(type)};
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 10px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.3);
            transform: translateX(100%);
            transition: transform 0.3s ease;
            pointer-events: auto;
            max-width: 300px;
            word-wrap: break-word;
        `;
        notification.textContent = message;

        notificationContainer.appendChild(notification);

        // Animate in
        setTimeout(() => {
            notification.style.transform = 'translateX(0)';
        }, 100);

        // Auto-remove after 5 seconds
        setTimeout(() => {
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 5000);
    }

    getNotificationColor(type) {
        const colors = {
            success: 'linear-gradient(135deg, #4CAF50, #45a049)',
            error: 'linear-gradient(135deg, #f44336, #da190b)',
            warning: 'linear-gradient(135deg, #ff9800, #f57c00)',
            info: 'linear-gradient(135deg, #2196F3, #0b7dda)'
        };
        return colors[type] || colors.info;
    }

    handleQuantumCollapse(collapseData) {
        console.log('⚡ Handling quantum collapse:', collapseData);
        
        // Update the quantum display
        this.updateQuantumDisplay(collapseData);
        
        // Show special collapse notification
        this.showNotification(
            `🌟 Quantum Collapse! Optimal style: ${collapseData.optimal_style}`,
            'success'
        );
        
        // Trigger special UI effects
        this.triggerCollapseEffects();
    }

    triggerCollapseEffects() {
        // Add special visual effects for quantum collapse
        const body = document.body;
        body.style.animation = 'quantum-pulse 2s ease-in-out';
        
        // Add temporary CSS animation
        const style = document.createElement('style');
        style.textContent = `
            @keyframes quantum-pulse {
                0%, 100% { 
                    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                }
                50% { 
                    background: linear-gradient(135deg, #FFD700 0%, #FFA500 100%);
                }
            }
        `;
        document.head.appendChild(style);
        
        // Remove animation after completion
        setTimeout(() => {
            body.style.animation = '';
            document.head.removeChild(style);
        }, 2000);
    }

    // Cleanup method
    destroy() {
        // Stop emotion detection
        if (this.emotionDetectionInterval) {
            clearInterval(this.emotionDetectionInterval);
        }
        
        // Stop camera stream
        if (this.cameraStream) {
            this.cameraStream.getTracks().forEach(track => track.stop());
        }
        
        // Disconnect socket
        if (this.socket) {
            this.socket.disconnect();
        }
        
        console.log('🧠 Quantum Learning Connector destroyed');
    }
}

// Enhanced simulation override for seamless integration
function enhanceExistingSimulations() {
    // Store reference to original simulation function if it exists
    const originalSimulateInteraction = window.simulateInteraction;
    
    // Override the simulation function
    window.simulateInteraction = async function(scenarioType) {
        try {
            // Run original frontend simulation first
            if (originalSimulateInteraction) {
                originalSimulateInteraction(scenarioType);
            }
            
            // Then run backend integration
            if (window.quantumConnector) {
                await window.quantumConnector.simulateInteractionWithBackend(scenarioType);
            } else {
                console.warn('⚠️ Quantum connector not initialized');
            }
        } catch (error) {
            console.error('❌ Enhanced simulation error:', error);
        }
    };
    
    // Override reset system function
    const originalResetSystem = window.resetSystem;
    window.resetSystem = function() {
        try {
            // Run original reset
            if (originalResetSystem) {
                originalResetSystem();
            }
            
            // Reset backend state
            if (window.quantumConnector) {
                // Reinitialize connector
                window.quantumConnector.destroy();
                window.quantumConnector = new QuantumLearningConnector();
            }
        } catch (error) {
            console.error('❌ Enhanced reset error:', error);
        }
    };
}

// Auto-initialization when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    console.log('🚀 Initializing Quantum Learning Platform...');
    
    // Wait a bit for the original scripts to load
    setTimeout(() => {
        try {
            // Initialize the quantum connector
            window.quantumConnector = new QuantumLearningConnector();
            
            // Enhance existing simulation functions
            enhanceExistingSimulations();
            
            // Add enhanced UI features
            addEnhancedUIFeatures();
            
            console.log('✅ Quantum Learning Platform fully initialized!');
            
        } catch (error) {
            console.error('❌ Initialization failed:', error);
        }
    }, 1000);
});

function addEnhancedUIFeatures() {
    // Add real-time status indicator
    const header = document.querySelector('.header');
    if (header) {
        const statusDiv = document.createElement('div');
        statusDiv.innerHTML = `
            <div style="
                display: flex; 
                justify-content: center; 
                align-items: center; 
                gap: 10px;
                margin-top: 10px;
                font-size: 0.9em;
                opacity: 0.8;
            ">
                <span id="backendStatus">🔄 Connecting to AI Backend...</span>
                <span id="cameraStatus">📹 Initializing camera...</span>
            </div>
        `;
        header.appendChild(statusDiv);
    }
    
    // Add keyboard shortcuts
    document.addEventListener('keydown', function(event) {
        if (event.ctrlKey || event.metaKey) {
            switch(event.key) {
                case '1':
                    event.preventDefault();
                    window.simulateInteraction('confused');
                    break;
                case '2':
                    event.preventDefault();
                    window.simulateInteraction('engaged');
                    break;
                case '3':
                    event.preventDefault();
                    window.simulateInteraction('bored');
                    break;
                case '4':
                    event.preventDefault();
                    window.simulateInteraction('frustrated');
                    break;
                case '5':
                    event.preventDefault();
                    window.simulateInteraction('optimal');
                    break;
                case 'r':
                    event.preventDefault();
                    window.resetSystem();
                    break;
            }
        }
    });
    
    // Add tooltips for keyboard shortcuts
    const controlsPanel = document.querySelector('.simulation-controls');
    if (controlsPanel) {
        const shortcutsDiv = document.createElement('div');
        shortcutsDiv.innerHTML = `
            <small style="opacity: 0.7; margin-top: 10px; display: block;">
                💡 Keyboard shortcuts: Ctrl+1-5 for simulations, Ctrl+R to reset
            </small>
        `;
        controlsPanel.appendChild(shortcutsDiv);
    }
    
    console.log('✨ Enhanced UI features added');
}

// Export for module usage if needed
if (typeof module !== 'undefined' && module.exports) {
    module.exports = QuantumLearningConnector;
}