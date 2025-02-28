
# Tech Case 20: Reaction Timer Game




## Description

This is a simple reaction timer game where players shake the phone to start, then wait for the "TAP!" signal and tap the screen as quickly as possible. The game records reaction times, keeps a local leaderboard with the best scores, and includes sound and vibration feedback to enhance the experience. Using the accelerometer and gyroscope, the app detects intentional shakes while ignoring accidental ones. Players can also share their best times directly from the app.

## Project Structure

- **GameView.swift**  
This file displays the main screen during gameplay. It manages the layout, animations and detects the shake gesture.

- **GameViewModel.swift**  
This file contains the main logic of the game. It controls the countdown, generates a random delay, measures the reaction time, plays sounds, triggers vibrations and updates the leaderboard.

- **ShakeGestureManager.swift**  
This file detects the shake gesture that starts the game.

- **Assets**  
This folder contains all images, icons and sounds used in the application.

- **Reaction_Timer_GameApp.swift**  
This file launches the application and shows the initial screen.

## Download the project: Instructions
To open this project on your device, follow these steps:

1. Make sure you have **Git** installed on your device. If not, download it [here](https://git-scm.com/downloads).
2. Make sure you have **Xcode** installed. If not, download it from the [App Store](https://apps.apple.com/us/app/xcode/id497799835).
3. Copy the link of **this** repository: [https://git.fhict.nl/I524517/reaction-timer-game](https://git.fhict.nl/I524517/reaction-timer-game).
4. Open a terminal on your device and navigate through the folders using the **cd** command.
5. Once you are inside the desired directory, run the command:
    **git clone https://git.fhict.nl/I524517/reaction-timer-game**
6. After the project is cloned, open **Xcode** and choose **File > Open**, then select the project folder.
7. The project is now ready to run on your device or simulator. _Enjoy_!
## Yordan Markov

- Student number: 5056136
- Email: yordanmarkov2004@gmail.com
- Mobile: +359882064129
Fontys University of Applied Sciences, 2025

