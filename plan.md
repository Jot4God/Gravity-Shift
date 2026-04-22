# Gravity Shift — Project Plan

## Project Overview
Gravity Shift é um jogo 2D arcade desenvolvido em Swift utilizando SpriteKit.  
O jogador controla um objeto que se move automaticamente e deve alternar entre o chão e o teto ao inverter a gravidade, evitando obstáculos ao longo do percurso.

O jogo é focado em simplicidade, rapidez de reação e jogabilidade contínua.

---

## Main Objective
Criar um jogo funcional e fluido que demonstre:
- controlo de input (toque)
- uso de física básica
- deteção de colisões
- gestão de estados de jogo
- organização de código em Swift

---

## Core Idea
Ao contrário de jogos tradicionais onde o jogador salta, em Gravity Shift a única ação possível é inverter a gravidade.

Isto cria um sistema de controlo simples:
- um único input
- duas posições possíveis (chão / teto)
- decisões baseadas em timing

---

## Game Flow
1. O jogador inicia o jogo a partir do menu
2. A personagem começa a mover-se automaticamente
3. Obstáculos aparecem progressivamente
4. O jogador toca para inverter a gravidade
5. A dificuldade aumenta ao longo do tempo
6. Uma colisão termina o jogo
7. É apresentado o score final e opção de reiniciar

---

## Controls
- Tap no ecrã → inverter gravidade  
Sem botões adicionais, mantendo o jogo acessível e direto.

---

## Gameplay Systems

### Movement
- Deslocamento automático horizontal
- Velocidade ajustável ao longo do tempo

### Gravity System
- Alternância entre gravidade positiva e negativa
- Aplicada diretamente no `physicsWorld`

### Obstacles
- Gerados continuamente
- Posicionados no topo e na base
- Movem-se em direção ao jogador

### Collision
- Detetada através de `SKPhysicsBody`
- Qualquer contacto com obstáculo resulta em Game Over

### Scoring
- Baseado no tempo de sobrevivência
- Atualizado em tempo real

---

## 🛠️ Technical Setup

- **Language:** Swift  
- **IDE:** Xcode  
- **Framework:** SpriteKit  

### Key Components
- GameScene → lógica principal
- PlayerNode → comportamento do jogador
- Obstacle System → geração e movimento
- Physics Engine → colisões e gravidade

---

##  Project Structure
```text
GameViewController.swift   — inicia o jogo
GameScene.swift            — loop principal
PlayerNode.swift           — jogador
ObstacleSpawner.swift      — criação de obstáculos
MenuScene.swift            — menu inicial
GameOverScene.swift        — fim do jogo
Constants.swift            — configurações globais
