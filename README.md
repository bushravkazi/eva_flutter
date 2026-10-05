# EVANAMI 

\> Elderly Mental Wellness & Caregiver Support Ecosystem

\> Empowering cognitive health through accessible mini-games, personalized motor/memory care, and data-driven caregiver analytics. **EVANAMI** is a dual-role mobile application built using Flutter and Dart, engineered specifically for elderly cognitive health management and caregiver monitoring. The platform bridges the gap between daily cognitive exercises for seniors and continuous tracking for caregivers.

The application features an **Accessibility-First Elderly Mode** that includes personalized memory and motor games, guided wellness exercises, and high-contrast smart reminders. Concurrently, the **Caregiver Dashboard** grants family members or medical caregivers remote oversight over cognitive progress, game difficulty tuning, custom asset management (e.g., family face uploads), and appointment/medication scheduling backed by an **SQL relational database**.

# Key Features

### 1\. Elderly Mode (Accessibility-First UI)

Designed strictly according to accessibility standards for seniors with visual or motor impairments (large touch targets min $56 \\times 56\\text{ dp}$, high contrast, simplified navigation):

*   **Daily Welcome Hub:** Dynamic greetings ("Good Morning, \[Name\]") with a single-tap "Begin Your Day" routine.
    
*   **Smart Reminders Banner:** High-visibility banner highlighting active medication dosages and upcoming medical appointments with one-touch completion checking.
    
*   **Wellness & Exercise Module:** Guided step-by-step physical and mental wellness routines:
    
    *   **Tai Chi Walking & Gentle Exercises**
        
    *   **Chair Yoga & Guided Meditation**
        
*   **5 Core Cognitive Mini-Games:**
    
    1.  **Guess Who?:** Identifies family members, relatives, and close friends using caregiver-uploaded custom photos and names.
        
    2.  **Market Recall:** Shopping list memory game evaluating short-term pattern recall and daily living item recognition.
        
    3.  **Serial Math Chain:** Sequential arithmetic exercises designed to stimulate active problem-solving skills.
        
    4.  **Trace N Train:** Fine motor skill and hand precision assessment tracking motor tremor and drift.
        
    5.  **Dance Away:** Encourages physical activity through dances and interactive movements.
        

### 2\. Caregiver Mode (Analytics & Control Panel)

A comprehensive management interface protected by a role-switching verification system:

*   **Performance Analytics Dashboard:**
    
    *   Real-time charts detailing cognitive performance across games (fl\_chart).
        
    *   Accuracy trends (%), reaction speed tracking ($ms$), and error rates over time.
        
    *   Motor precision metrics derived from touch variance in line-tracing exercises.
        
*   **Game Personalization & Adaptability:**
    
    *   **Face Recognition Manager:** Upload photos of family members, input names, and assign relationships.
        
    *   **Difficulty Regulator:** Adjust game difficulty levels ($1$ to $5$), timer lengths, and item complexity per senior capability.
        
*   **Smart Reminders Manager (SQL-backed):**
    
    *   Schedule recurring medication notifications and healthcare appointments.
        
    *   Triggers background device notifications via flutter\_local\_notifications.


### Tech Stack
 *   Core Framework: Flutter 3.x (Dart 3.x)

 *   Primary Target Platforms: Mobile (iOS & Android)

 *   Database Engine: SQL (sqflite for local persistent storage / PostgreSQL integration)

 *   State Management: Provider / Riverpod

 *   Data Visualization: fl_chart

 *   Local Notifications: flutter_local_notifications

 *   Media & Asset Handling: image_picker, path_provider
   

Development Team — THINKING VOID
--------------------------------

EVANAMI is designed, architected, and built our team:

*   **Zoya Mushtaq Kazi**
    
*   **Anam Khan**
    
*   **Bushra Vahid Kazi**
    
*   **Hamnah Ansari**
    
*   **Iqra Mirza**
    
*   **Taha Khan**
    

📄 License
----------

This project is licensed under the **MIT License** — see the [LICENSE](https://www.google.com/search?q=LICENSE) file for complete details.
