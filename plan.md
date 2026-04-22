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

## Technical approach

O movimento será contínuo na horizontal, enquanto a gravidade será alterada diretamente durante o jogo.  
Os obstáculos serão gerados ao longo do tempo e movem-se em direção ao jogador.  

A deteção de colisões será feita através do sistema de física do SpriteKit.  
A pontuação será baseada no tempo de sobrevivência.

---

## MVP scope
Para garantir que o projeto é realizável, o foco será:

- Mecânica de inversão de gravidade funcional  
- Movimento automático do jogador  
- Obstáculos simples (topo e base)  
- Sistema de colisão com fim de jogo  
- Pontuação básica  
- Interface simples (iniciar jogo e reiniciar)

---

## 🛠️ Technical Setup

- **Language:** Swift  
- **IDE:** Xcode  
- **Framework:** SpriteKit  
