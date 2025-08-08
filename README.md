# LuminanceSurgeTrap

## Purpose & Goal

Create a Drosera-compatible smart contract trap that monitors key Ethereum network parameters — specifically block.basefee and block.gaslimit — and triggers alerts on significant fluctuations. Designed for high-frequency responsiveness, the trap activates when either parameter changes beyond 1% between consecutive blocks, enabling near real-time anomaly detection.

## Background & Motivation

Ethereum network parameters like basefee and gaslimit fluctuate constantly. Even small sharp changes may indicate:

Emerging network congestion,

Validator manipulations or MEV activity,

Transient network instabilities affecting DeFi and dApps,

Early warning signs of attacks or unusual conditions.

Capturing these rapid variations promptly is vital for maintaining robust monitoring and timely alerts.

## Core Functionality

LuminanceSurgeTrap collects block.basefee and block.gaslimit each block and compares current and previous values. If the percentage change in either basefee or gaslimit exceeds 1%, the trap signals a surge event.

## Expected Behavior

The trap will trigger frequently — approximately every 1–3 blocks — reflecting the 1% sensitivity threshold on basefee or gaslimit changes, making it highly reactive to network fluctuations.
