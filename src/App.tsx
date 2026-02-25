/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useRef } from 'react';
import { GoogleGenAI } from "@google/genai";
import { motion, AnimatePresence } from 'motion/react';
import { 
  Car, 
  Clock, 
  MapPin, 
  Shield, 
  Leaf, 
  Sparkles, 
  Play, 
  Loader2, 
  ChevronRight,
  Key,
  Info,
  CheckCircle2,
  Building2,
  Users as UsersIcon,
  ArrowRightLeft,
  TrendingDown,
  TrendingUp,
  AlertCircle,
  BarChart3,
  Globe2,
  Cpu,
  Milestone,
  Rocket,
  Handshake,
  Zap,
  DollarSign,
  UserCheck
} from 'lucide-react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

// --- Utilities ---
function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

// --- Types ---
interface Scene {
  id: string;
  title: string;
  description: string;
  prompt: string;
  imageSrc?: string;
}

interface Phase {
  title: string;
  icon: string;
  scenes: Scene[];
}

const PHASES: Phase[] = [
  {
    title: 'Phase 1: Morning Peak',
    icon: '🌅',
    scenes: [
      {
        id: '1.1',
        title: 'Prompt 1.1 — Morning Wake-up',
        description: 'Smartphone screen showing autonomous vehicle arrival notification, calm atmosphere, modern apartment.',
        prompt: 'early morning bedroom scene, soft sunrise light through window, young professional waking up, smartphone screen showing autonomous vehicle arrival notification, calm atmosphere, modern apartment, cozy and minimal',
        imageSrc: '/phase1-1.1.png'
      },
      {
        id: '1.2',
        title: 'Prompt 1.2 — Pick-up at Home',
        description: 'Autonomous electric vehicle waiting in front of a suburban home, person walking out with coffee.',
        prompt: 'autonomous electric vehicle waiting in front of a suburban home, person walking out slightly sleepy with coffee, quiet neighborhood street, clean futuristic design, friendly and safe feeling',
        imageSrc: '/phase1-1.2.png'
      },
      {
        id: '1.3',
        title: 'Prompt 1.3 — Stable Traffic Flow',
        description: 'Aerial view of city during morning rush hour, traffic flowing smoothly in coordinated patterns.',
        prompt: 'aerial view of city during morning rush hour, traffic flowing smoothly in coordinated patterns, multiple autonomous vehicles moving in organized lanes, sense of stability and efficiency',
        imageSrc: '/phase1-1.3.png'
      }
    ]
  },
  {
    title: 'Phase 2: Off-Peak Operations',
    icon: '🏙',
    scenes: [
      {
        id: '2.1',
        title: 'Prompt 2.1 — Distributed Fleet',
        description: 'City map perspective with autonomous vehicles distributed across different neighborhoods.',
        prompt: 'city map perspective with autonomous vehicles distributed across different neighborhoods, visual sense of dynamic rebalancing, subtle data lines connecting areas, urban mobility network',
        imageSrc: '/phase2-2.1.png'
      },
      {
        id: '2.2',
        title: 'Prompt 2.2 — Taxi Mode Service',
        description: 'Person requesting ride on smartphone, autonomous vehicle arriving curbside.',
        prompt: 'person requesting ride on smartphone, autonomous vehicle arriving curbside, casual daytime city environment, relaxed and convenient mobility moment',
        imageSrc: '/phase2-2.2.png'
      },
      {
        id: '2.3',
        title: 'Prompt 2.3 — Charging & Maintenance',
        description: 'Fleet of autonomous vehicles charging at modern charging station, clean infrastructure.',
        prompt: 'fleet of autonomous vehicles charging at modern charging station, clean infrastructure, technicians or automated systems maintaining vehicles, efficient operations atmosphere',
        imageSrc: '/phase2-2.3.png'
      }
    ]
  },
  {
    title: 'Phase 3: Evening Peak',
    icon: '🌇',
    scenes: [
      {
        id: '3.1',
        title: 'Prompt 3.1 — Evening Pick-up',
        description: 'Office district at sunset, tired professional exiting building, autonomous vehicle waiting curbside.',
        prompt: 'office district at sunset, tired professional exiting building, autonomous vehicle waiting curbside, warm golden hour lighting, calm transition from workday',
        imageSrc: '/phase3-3.1.png'
      },
      {
        id: '3.2',
        title: 'Prompt 3.2 — Coordinated Peak Flow',
        description: 'City traffic at evening peak, autonomous vehicles forming structured movement patterns.',
        prompt: 'city traffic at evening peak, autonomous vehicles forming structured movement patterns, smooth traffic flow, subtle glowing paths indicating coordination',
        imageSrc: '/phase3-3.2.png'
      },
      {
        id: '3.3',
        title: 'Prompt 3.3 — Arriving Home',
        description: 'Quiet residential street at night, person stepping out of autonomous vehicle in front of home.',
        prompt: 'quiet residential street at night, person stepping out of autonomous vehicle in front of home, cozy lights from windows, peaceful mood',
        imageSrc: '/phase3-3.3.png'
      }
    ]
  },
  {
    title: 'Phase 4: Night Cycle',
    icon: '🌙',
    scenes: [
      {
        id: '4.1',
        title: 'Prompt 4.1 — Nighttime City',
        description: 'Nighttime city skyline, autonomous vehicles still operating with soft lights.',
        prompt: 'nighttime city skyline, autonomous vehicles still operating with soft lights, calm and futuristic urban environment, sense of continuous mobility',
        imageSrc: '/phase4-4.1.png'
      },
      {
        id: '4.2',
        title: 'Prompt 4.2 — System Preparation',
        description: 'Abstract control center visualization, digital dashboard with mobility data flows.',
        prompt: 'abstract control center visualization, digital dashboard with mobility data flows, city map with moving signals, futuristic system intelligence preparing for next day',
        imageSrc: '/phase4-4.2.png'
      }
    ]
  }
];

// --- Components ---

export default function App() {
  const [selectedScene, setSelectedScene] = useState<Scene>(PHASES[0].scenes[0]);

  return (
    <div className="min-h-screen bg-[#050505] text-white font-sans selection:bg-emerald-500/30">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 border-b border-white/5 bg-black/50 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
          <a href="#vision" className="flex items-center gap-2">
            <img 
              src="/site-logo.png"
              alt="RoamingOS"
              className="h-8 w-auto object-contain"
            />
          </a>
          <div className="hidden md:flex items-center gap-8 text-sm font-medium text-white/60">
            <a href="#vision" className="hover:text-white transition-colors">Vision</a>
            <a href="#problem" className="hover:text-white transition-colors">Problem</a>
            <a href="#solution" className="hover:text-white transition-colors">Solution</a>
            <a href="#structure" className="hover:text-white transition-colors">Structure</a>
            <a href="#market" className="hover:text-white transition-colors">Market</a>
            <a href="#roadmap" className="hover:text-white transition-colors">Roadmap</a>
          </div>
          <div className="flex items-center gap-2 text-emerald-400 text-sm font-medium">
            <Sparkles className="w-4 h-4" />
            Future Ready
          </div>
        </div>
      </nav>

      <main>
        {/* Hero Section */}
        <section id="vision" className="relative pt-40 pb-20 px-6 overflow-hidden">
          <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full h-full pointer-events-none">
            <div className="absolute top-0 left-1/4 w-[500px] h-[500px] bg-emerald-500/10 blur-[120px] rounded-full" />
            <div className="absolute bottom-0 right-1/4 w-[500px] h-[500px] bg-blue-500/10 blur-[120px] rounded-full" />
          </div>

          <div className="max-w-7xl mx-auto relative">
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8 }}
              className="max-w-4xl"
            >
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold uppercase tracking-wider mb-8">
                <Globe2 className="w-3 h-3" />
                The Coordination Layer for Autonomous Mobility
              </div>
              <h1 className="text-6xl md:text-8xl font-light tracking-tighter leading-[0.9] mb-8">
                Scaling the future <span className="italic text-emerald-400">without congestion</span>.
              </h1>
              <p className="text-xl md:text-2xl text-white/60 font-light leading-relaxed mb-12 max-w-2xl">
                Roaming OS enables autonomous fleets to operate not just as transportation providers, but as stabilizing elements of city traffic systems.
              </p>
              
              <div className="flex flex-wrap gap-4">
                <a href="#generate" className="px-8 py-4 bg-emerald-500 text-black rounded-full font-bold hover:bg-emerald-400 transition-all flex items-center gap-2">
                  <Play className="w-4 h-4 fill-current" />
                  View the Vision
                </a>
                <a href="#problem" className="px-8 py-4 bg-white/5 border border-white/10 rounded-full font-bold hover:bg-white/10 transition-all">
                  Read the Thesis
                </a>
              </div>
            </motion.div>
          </div>
        </section>

        {/* Problem Section */}
        <section id="problem" className="py-24 px-6 border-t border-white/5">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-20">
              <div>
                <h2 className="text-4xl font-light tracking-tight mb-8">The Structural Inefficiency</h2>
                <div className="space-y-8">
                  <div className="flex gap-6">
                    <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center flex-shrink-0">
                      <TrendingDown className="w-6 h-6 text-red-400" />
                    </div>
                    <div>
                      <h4 className="text-lg font-medium mb-2">High Cost, Low Utility</h4>
                      <p className="text-white/40 text-sm leading-relaxed">
                        Privately owned vehicles are characterized by extremely low utilization and high ownership costs, averaging <span className="text-white">$11,577/year</span>.
                      </p>
                    </div>
                  </div>
                  <div className="flex gap-6">
                    <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center flex-shrink-0">
                      <AlertCircle className="w-6 h-6 text-red-400" />
                    </div>
                    <div>
                      <h4 className="text-lg font-medium mb-2">The Scaling Bottleneck</h4>
                      <p className="text-white/40 text-sm leading-relaxed">
                        The next constraint isn't technical feasibility—it's system impact. Cities won't allow fleets to scale if they worsen congestion.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
              <div className="grid grid-cols-2 gap-4">
                <div className="p-8 rounded-3xl bg-white/5 border border-white/10 flex flex-col justify-between">
                  <span className="text-white/40 text-sm">Avg. Monthly Cost</span>
                  <div className="text-4xl font-light text-red-400 mt-4">$965</div>
                  <span className="text-xs text-white/20 mt-2">Per vehicle in the U.S.</span>
                </div>
                <div className="p-8 rounded-3xl bg-white/5 border border-white/10 flex flex-col justify-between">
                  <span className="text-white/40 text-sm">Utilization Rate</span>
                  <div className="text-4xl font-light text-red-400 mt-4">&lt;5%</div>
                  <span className="text-xs text-white/20 mt-2">Most cars sit idle</span>
                </div>
                <div className="col-span-2 p-8 rounded-3xl bg-red-500/10 border border-red-500/20">
                  <p className="text-red-400 font-medium italic">
                    "The bottleneck is shifting from technical feasibility to system impact."
                  </p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Solution Section */}
        <section id="solution" className="py-24 px-6 bg-emerald-500/[0.02] border-y border-white/5">
          <div className="max-w-7xl mx-auto">
            <div className="text-center mb-16">
              <h2 className="text-4xl md:text-5xl font-light tracking-tight mb-4">Roaming OS + Tattle Model</h2>
              <p className="text-white/40 max-w-2xl mx-auto">
                A system-level orchestration platform enabling fleets to dynamically switch between structured commuting and on-demand services.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-12 mb-20">
              <div className="p-10 rounded-[2rem] bg-white/5 border border-white/10">
                <div className="w-12 h-12 rounded-full bg-emerald-500/20 flex items-center justify-center mb-6">
                  <Clock className="w-6 h-6 text-emerald-400" />
                </div>
                <h3 className="text-2xl font-light mb-4">Peak Hours: Shuttle</h3>
                <p className="text-white/40 leading-relaxed mb-6">
                  Structured commuting for short and long distances. Home to Workplace, or Home to Transit Hub.
                </p>
                <div className="flex items-center gap-2 text-emerald-400 text-sm font-medium">
                  <CheckCircle2 className="w-4 h-4" />
                  Subscription-based reliability
                </div>
              </div>
              <div className="p-10 rounded-[2rem] bg-white/5 border border-white/10">
                <div className="w-12 h-12 rounded-full bg-blue-500/20 flex items-center justify-center mb-6">
                  <Zap className="w-6 h-6 text-blue-400" />
                </div>
                <h3 className="text-2xl font-light mb-4">Off-Peak: Taxi</h3>
                <p className="text-white/40 leading-relaxed mb-6">
                  The same vehicles switch to on-demand mode, offering convenient trips at discounted prices.
                </p>
                <div className="flex items-center gap-2 text-blue-400 text-sm font-medium">
                  <CheckCircle2 className="w-4 h-4" />
                  Maximizing fleet utilization
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Generate Section (Visualizing the Solution) */}
        <section id="generate" className="py-24 px-6">
          <div className="max-w-7xl mx-auto">
            <div>
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold uppercase tracking-wider mb-6">
                <Sparkles className="w-3 h-3" />
                RoamingOS Engine
              </div>
              <h2 className="text-4xl font-light tracking-tight mb-6">Visualize the Future</h2>
              <p className="text-white/60 mb-12 max-w-md">
                Explore the RoamingOS vision through cinematic scenarios of the future urban commute.
              </p>

              <div className="space-y-12">
                {PHASES.map((phase, phaseIdx) => {
                  const phaseNumber = phaseIdx + 1;
                  const isSelectedInPhase = selectedScene.id.startsWith(`${phaseNumber}.`);

                  return (
                    <div 
                      key={phaseIdx} 
                      className="md:grid md:grid-cols-[minmax(0,1.1fr)_minmax(0,1.4fr)] md:gap-10 space-y-4 md:space-y-0"
                    >
                      <div>
                        <div className="flex items-center gap-2 text-white/40 text-sm font-semibold uppercase tracking-widest px-2 mb-3">
                          <span>{phase.icon}</span>
                          <span>{phase.title}</span>
                        </div>
                        <div className="grid grid-cols-1 gap-3">
                          {phase.scenes.map((scene) => (
                            <button
                              key={scene.id}
                              onClick={() => setSelectedScene(scene)}
                              className={cn(
                                "w-full text-left p-4 rounded-xl border transition-all duration-300",
                                selectedScene.id === scene.id 
                                  ? "bg-white text-black border-white" 
                                  : "bg-transparent border-white/10 hover:border-white/30"
                              )}
                            >
                              <div className="flex items-start gap-3">
                                {scene.imageSrc && (
                                  <img
                                    src={scene.imageSrc}
                                    alt={`${scene.title} thumbnail`}
                                    className="w-20 h-14 rounded-lg object-cover flex-shrink-0 border border-black/10"
                                  />
                                )}
                                <div className="min-w-0 flex-1">
                                  <div className="flex justify-between items-center mb-1 gap-2">
                                    <span className="text-base font-medium leading-tight">{scene.title}</span>
                                    {selectedScene.id === scene.id && <ChevronRight className="w-4 h-4 flex-shrink-0" />}
                                  </div>
                                  <p className={cn(
                                    "text-xs line-clamp-2",
                                    selectedScene.id === scene.id ? "text-black/60" : "text-white/40"
                                  )}>
                                    {scene.description}
                                  </p>
                                </div>
                              </div>
                            </button>
                          ))}
                        </div>
                      </div>

                      <div className="mt-6 md:mt-0 relative">
                        <div className={cn(
                          "w-full rounded-3xl bg-white/5 border border-white/10 overflow-hidden flex flex-col relative shadow-2xl",
                          isSelectedInPhase &&
                            ['1.1', '1.2', '1.3', '2.1', '2.2', '2.3', '3.1', '3.2', '3.3', '4.1', '4.2'].includes(selectedScene.id)
                            ? "min-h-0"
                            : "aspect-video"
                        )}>
                          {isSelectedInPhase &&
                           ['1.1', '1.2', '1.3', '2.1', '2.2', '2.3', '3.1', '3.2', '3.3', '4.1', '4.2'].includes(selectedScene.id) ? (
                            <>
                              <div className="w-full aspect-video flex-shrink-0 overflow-hidden rounded-t-3xl">
                                <img
                                  src={`/phase${selectedScene.id.split('.')[0]}-${selectedScene.id}.png`}
                                  alt={selectedScene.title}
                                  className="w-full h-full object-cover"
                                />
                              </div>
                              <div className="p-5 border-t border-white/10 bg-white/5">
                                <h3 className="text-xl font-medium text-white mb-2">{selectedScene.title}</h3>
                                <p className="text-sm text-white/70 mb-2">{selectedScene.description}</p>
                                <p className="text-sm text-white/50 italic">"{selectedScene.prompt}"</p>
                              </div>
                            </>
                          ) : (
                            <div className="flex flex-col items-center justify-center gap-6 text-white/20 p-12 text-center flex-1">
                              <div className="w-20 h-20 bg-white/5 rounded-full flex items-center justify-center mb-2">
                                <Sparkles className="w-10 h-10" />
                              </div>
                              <div>
                                <h3 className="text-2xl font-light text-white/80 mb-2">
                                  {isSelectedInPhase ? selectedScene.title : `${phase.title} Visual`}
                                </h3>
                                <p className="text-sm text-white/40 max-w-sm mx-auto italic">
                                  {isSelectedInPhase ? `"${selectedScene.prompt}"` : "Select a prompt on the left to visualize this phase."}
                                </p>
                              </div>
                            </div>
                          )}
                        </div>

                        {/* Decorative Elements */}
                        <div className="absolute -bottom-6 -right-6 w-32 h-32 bg-emerald-500/20 blur-3xl rounded-full" />
                        <div className="absolute -top-6 -left-6 w-32 h-32 bg-blue-500/20 blur-3xl rounded-full" />
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </section>

        {/* Structure Comparison Section */}
        <section id="structure" className="py-24 px-6 relative overflow-hidden">
          <div className="max-w-7xl mx-auto">
            <div className="text-center mb-16">
              <h2 className="text-4xl md:text-5xl font-light tracking-tight mb-4">The Structural Shift</h2>
              <p className="text-white/40 max-w-2xl mx-auto">
                Moving from conflicting incentives to a unified ecosystem where every stakeholder wins.
              </p>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
              {/* Traditional Structure */}
              <div className="relative p-8 rounded-3xl bg-red-500/[0.02] border border-white/5 overflow-hidden group">
                <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                  <AlertCircle className="w-24 h-24 text-red-500" />
                </div>
                
                <div className="mb-10">
                  <span className="px-3 py-1 rounded-full bg-red-500/10 border border-red-500/20 text-red-400 text-xs font-semibold uppercase tracking-wider">
                    Traditional Traffic Structure
                  </span>
                  <h3 className="text-2xl font-light mt-4 text-white/80">Conflicting Incentives</h3>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-white/60">
                      <Car className="w-4 h-4" />
                      <span className="text-sm font-medium">Car Companies</span>
                    </div>
                    <ul className="text-xs text-white/30 space-y-2">
                      <li>• Sell more vehicles</li>
                      <li>• Increase road usage</li>
                    </ul>
                  </div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-white/60">
                      <Building2 className="w-4 h-4" />
                      <span className="text-sm font-medium">Governments</span>
                    </div>
                    <ul className="text-xs text-white/30 space-y-2">
                      <li>• Reduce congestion</li>
                      <li>• Limit traffic growth</li>
                    </ul>
                  </div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-white/60">
                      <UsersIcon className="w-4 h-4" />
                      <span className="text-sm font-medium">Users</span>
                    </div>
                    <ul className="text-xs text-white/30 space-y-2">
                      <li>• Need mobility</li>
                      <li>• Bear high cost & stress</li>
                    </ul>
                  </div>
                </div>

                <div className="pt-6 border-t border-white/5">
                  <div className="flex items-start gap-3 text-red-400/80">
                    <TrendingDown className="w-5 h-5 mt-0.5 flex-shrink-0" />
                    <p className="text-sm italic">
                      "Everyone optimizes locally, the system suffers globally."
                    </p>
                  </div>
                </div>
              </div>

              {/* Roaming OS Structure */}
              <div className="relative p-8 rounded-3xl bg-emerald-500/[0.02] border border-emerald-500/10 overflow-hidden group">
                <div className="absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity">
                  <Sparkles className="w-24 h-24 text-emerald-500" />
                </div>

                <div className="mb-10">
                  <span className="px-3 py-1 rounded-full bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-semibold uppercase tracking-wider">
                    Roaming OS Structure
                  </span>
                  <h3 className="text-2xl font-light mt-4 text-emerald-400">Aligned Incentives</h3>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-emerald-400/60">
                      <Car className="w-4 h-4" />
                      <span className="text-sm font-medium">Mobility Operators</span>
                    </div>
                    <ul className="text-xs text-white/40 space-y-2">
                      <li>• Higher utilization</li>
                      <li>• Scalable operations</li>
                    </ul>
                  </div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-emerald-400/60">
                      <Building2 className="w-4 h-4" />
                      <span className="text-sm font-medium">Cities</span>
                    </div>
                    <ul className="text-xs text-white/40 space-y-2">
                      <li>• Improved traffic stability</li>
                      <li>• Better policy outcomes</li>
                    </ul>
                  </div>
                  <div className="space-y-3">
                    <div className="flex items-center gap-2 text-emerald-400/60">
                      <UsersIcon className="w-4 h-4" />
                      <span className="text-sm font-medium">Users</span>
                    </div>
                    <ul className="text-xs text-white/40 space-y-2">
                      <li>• Lower cost mobility</li>
                      <li>• Reliable service</li>
                    </ul>
                  </div>
                </div>

                <div className="pt-6 border-t border-white/5">
                  <div className="flex items-start gap-3 text-emerald-400">
                    <TrendingUp className="w-5 h-5 mt-0.5 flex-shrink-0" />
                    <p className="text-sm font-medium">
                      "The system improves as each stakeholder benefits."
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Market Section */}
        <section id="market" className="py-24 px-6 border-y border-white/5 bg-white/[0.01]">
          <div className="max-w-7xl mx-auto">
            <div className="flex flex-col lg:flex-row gap-20 items-center">
              <div className="flex-1">
                <h2 className="text-4xl font-light tracking-tight mb-6">A Venture-Scale Opportunity</h2>
                <p className="text-white/40 mb-10 leading-relaxed">
                  With 120 million car-dependent commuters in the U.S., the shift toward mobility-as-a-service represents a multi-trillion dollar market.
                </p>
                <div className="space-y-6">
                  <div className="flex items-center justify-between p-4 rounded-xl bg-white/5 border border-white/10">
                    <span className="text-white/60">TAM (U.S. Commuters)</span>
                    <span className="text-xl font-medium text-emerald-400">$2.1 Trillion</span>
                  </div>
                  <div className="flex items-center justify-between p-4 rounded-xl bg-white/5 border border-white/10">
                    <span className="text-white/60">SAM (Metro Commuters)</span>
                    <span className="text-xl font-medium text-emerald-400">$54 Billion</span>
                  </div>
                  <div className="flex items-center justify-between p-4 rounded-xl bg-emerald-500/10 border border-emerald-500/20">
                    <span className="text-emerald-400 font-medium">SOM (1% Penetration)</span>
                    <span className="text-xl font-bold text-emerald-400">$540 Million</span>
                  </div>
                </div>
              </div>
              <div className="flex-1 grid grid-cols-1 gap-6">
                <div className="p-8 rounded-3xl bg-white/5 border border-white/10">
                  <h4 className="text-lg font-medium mb-4 flex items-center gap-2">
                    <DollarSign className="w-5 h-5 text-emerald-400" />
                    Business Model
                  </h4>
                  <ul className="space-y-4 text-sm text-white/40">
                    <li className="flex items-center gap-3">
                      <div className="w-6 h-6 rounded-full bg-white/5 flex items-center justify-center text-[10px] text-white/60">1</div>
                      Subscription commuting fees
                    </li>
                    <li className="flex items-center gap-3">
                      <div className="w-6 h-6 rounded-full bg-white/5 flex items-center justify-center text-[10px] text-white/60">2</div>
                      Off-peak on-demand rides
                    </li>
                    <li className="flex items-center gap-3">
                      <div className="w-6 h-6 rounded-full bg-white/5 flex items-center justify-center text-[10px] text-white/60">3</div>
                      Enterprise commuting partnerships
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Technology & Roadmap */}
        <section id="roadmap" className="py-24 px-6">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-20">
              <div>
                <h2 className="text-4xl font-light tracking-tight mb-12 flex items-center gap-4">
                  <Cpu className="w-10 h-10 text-emerald-400" />
                  Strategic Moat
                </h2>
                <div className="space-y-10">
                  <div className="relative pl-8 border-l border-white/10">
                    <div className="absolute -left-1.5 top-0 w-3 h-3 rounded-full bg-emerald-500" />
                    <h4 className="text-lg font-medium mb-2">Technical Moat</h4>
                    <p className="text-sm text-white/40">AI Agent-based orchestration and stop-and-go wave mitigation algorithms for traffic stability.</p>
                  </div>
                  <div className="relative pl-8 border-l border-white/10">
                    <div className="absolute -left-1.5 top-0 w-3 h-3 rounded-full bg-emerald-500" />
                    <h4 className="text-lg font-medium mb-2">System Moat</h4>
                    <p className="text-sm text-white/40">Bridges autonomous fleets and city infrastructure, creating a unique coordination layer that scales with urban demand.</p>
                  </div>
                  <div className="relative pl-8 border-l border-white/10">
                    <div className="absolute -left-1.5 top-0 w-3 h-3 rounded-full bg-emerald-500" />
                    <h4 className="text-lg font-medium mb-2">Potential Policy Moat</h4>
                    <p className="text-sm text-white/40">Alignment with city-level traffic reliability goals creates a regulatory barrier to entry for non-coordinated fleets.</p>
                  </div>
                </div>
              </div>
              
              <div>
                <h2 className="text-4xl font-light tracking-tight mb-12 flex items-center gap-4">
                  <Milestone className="w-10 h-10 text-emerald-400" />
                  Roadmap
                </h2>
                <div className="grid grid-cols-1 gap-4">
                  {[
                    { phase: "Phase 0", title: "Simulation Validation", status: "Complete" },
                    { phase: "Phase 1", title: "Algorithm Prototype", status: "In Progress" },
                    { phase: "Phase 2", title: "MVP & Campus Pilot", status: "Q3 2026" },
                    { phase: "Phase 3", title: "Enterprise Partnerships", status: "2027" },
                    { phase: "Phase 4", title: "City-Level Orchestration", status: "2028+" }
                  ].map((item, i) => (
                    <div key={i} className="p-4 rounded-xl bg-white/5 border border-white/10 flex items-center justify-between">
                      <div>
                        <span className="text-[10px] uppercase tracking-widest text-emerald-400 font-bold">{item.phase}</span>
                        <h5 className="font-medium text-sm">{item.title}</h5>
                      </div>
                      <span className="text-xs text-white/20">{item.status}</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Team Section */}
        <section className="py-24 px-6 bg-emerald-500/[0.02] border-t border-white/5">
          <div className="max-w-7xl mx-auto">
            <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-8">
              <div className="max-w-xl">
                <h2 className="text-4xl font-light tracking-tight mb-4">The Team</h2>
                <p className="text-white/40">
                  Founded by PhD researchers from UC Berkeley and MIT specializing in transportation systems, optimization, and autonomous mobility.
                </p>
              </div>
              <div className="flex gap-8 items-center">
                {/* 左：MIT */}
                <div className="flex flex-col items-center gap-3">
                  <div className="h-24 w-32 px-4 py-3 rounded-xl bg-white flex items-center justify-center shadow-lg transform hover:scale-105 transition-transform overflow-hidden">
                    <img 
                      src="/mit-logo.svg" 
                      alt="MIT" 
                      className="h-full w-auto object-contain"
                    />
                  </div>
                </div>
                {/* 右：Berkeley */}
                <div className="flex flex-col items-center gap-3">
                  <div className="h-24 w-32 px-4 py-3 rounded-xl bg-white flex items-center justify-center shadow-lg transform hover:scale-105 transition-transform overflow-hidden">
                    <img 
                      src="/berkeley.png" 
                      alt="UC Berkeley" 
                      className="h-full w-auto object-contain"
                    />
                  </div>
                </div>
              </div>
            </div>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
              <div className="p-8 rounded-3xl bg-white/5 border border-white/10 flex items-center gap-6">
                <div className="w-16 h-16 rounded-full bg-emerald-500/20 flex items-center justify-center">
                  <UserCheck className="w-8 h-8 text-emerald-400" />
                </div>
                <div>
                  <h4 className="text-xl font-medium">System Positioning</h4>
                  <p className="text-sm text-white/40">Bridges fleets and city systems through policy-aligned deployment.</p>
                </div>
              </div>
              <div className="p-8 rounded-3xl bg-white/5 border border-white/10 flex items-center gap-6">
                <div className="w-16 h-16 rounded-full bg-emerald-500/20 flex items-center justify-center">
                  <Rocket className="w-8 h-8 text-emerald-400" />
                </div>
                <div>
                  <h4 className="text-xl font-medium">Execution Speed</h4>
                  <p className="text-sm text-white/40">Rapid iteration and modeling supported by academic collaboration.</p>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Stakeholder Value Section */}
        <section id="impact" className="py-24 px-6 border-t border-white/5">
          <div className="max-w-7xl mx-auto">
            <div className="text-center mb-16">
              <h2 className="text-4xl font-light tracking-tight mb-4">Stakeholder Value</h2>
              <p className="text-white/40 max-w-2xl mx-auto">
                Roaming OS doesn't just move people; it orchestrates a safer, more efficient, and more inclusive urban fabric.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {/* User Value */}
              <div className="p-8 rounded-3xl bg-white/5 border border-white/10">
                <div className="w-10 h-10 rounded-full bg-emerald-500/10 flex items-center justify-center mb-6">
                  <UserCheck className="w-5 h-5 text-emerald-400" />
                </div>
                <h4 className="text-xl font-medium mb-4">For Users</h4>
                <ul className="space-y-3 text-sm text-white/40">
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-400 mt-0.5 flex-shrink-0" />
                    20–50% cost savings vs car ownership
                  </li>
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-400 mt-0.5 flex-shrink-0" />
                    Safer & more inclusive for vulnerable groups
                  </li>
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-emerald-400 mt-0.5 flex-shrink-0" />
                    Predictable, stress-free travel time
                  </li>
                </ul>
              </div>

              {/* Fleet Value */}
              <div className="p-8 rounded-3xl bg-white/5 border border-white/10">
                <div className="w-10 h-10 rounded-full bg-blue-500/10 flex items-center justify-center mb-6">
                  <Zap className="w-5 h-5 text-blue-400" />
                </div>
                <h4 className="text-xl font-medium mb-4">For Fleet Operators</h4>
                <ul className="space-y-3 text-sm text-white/40">
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-blue-400 mt-0.5 flex-shrink-0" />
                    Higher utilization through Tattle Model
                  </li>
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-blue-400 mt-0.5 flex-shrink-0" />
                    Independent system performance validation
                  </li>
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-blue-400 mt-0.5 flex-shrink-0" />
                    Regulatory acceptance through alignment
                  </li>
                </ul>
              </div>

              {/* City Value */}
              <div className="p-8 rounded-3xl bg-white/5 border border-white/10">
                <div className="w-10 h-10 rounded-full bg-purple-500/10 flex items-center justify-center mb-6">
                  <Building2 className="w-5 h-5 text-purple-400" />
                </div>
                <h4 className="text-xl font-medium mb-4">For Cities</h4>
                <ul className="space-y-3 text-sm text-white/40">
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-purple-400 mt-0.5 flex-shrink-0" />
                    Reduced demand volatility & congestion
                  </li>
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-purple-400 mt-0.5 flex-shrink-0" />
                    Improved traffic stability (Wave Mitigation)
                  </li>
                  <li className="flex items-start gap-2">
                    <CheckCircle2 className="w-4 h-4 text-purple-400 mt-0.5 flex-shrink-0" />
                    Measurable throughput improvements
                  </li>
                </ul>
              </div>
            </div>
          </div>
        </section>

        {/* Why Now & GTM Section */}
        <section className="py-24 px-6 bg-white/[0.02] border-y border-white/5">
          <div className="max-w-7xl mx-auto">
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-20">
              <div>
                <h2 className="text-4xl font-light tracking-tight mb-8">Why Now?</h2>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-6">
                  <div className="p-6 rounded-2xl bg-white/5 border border-white/10">
                    <Rocket className="w-6 h-6 text-emerald-400 mb-4" />
                    <h5 className="font-medium mb-2">Scaling Phase</h5>
                    <p className="text-xs text-white/40">Autonomous fleets are entering large-scale deployment.</p>
                  </div>
                  <div className="p-6 rounded-2xl bg-white/5 border border-white/10">
                    <TrendingUp className="w-6 h-6 text-emerald-400 mb-4" />
                    <h5 className="font-medium mb-2">Rising Costs</h5>
                    <p className="text-xs text-white/40">Car ownership costs are at an all-time high ($11k+/year).</p>
                  </div>
                  <div className="p-6 rounded-2xl bg-white/5 border border-white/10">
                    <Shield className="w-6 h-6 text-emerald-400 mb-4" />
                    <h5 className="font-medium mb-2">Policy Pressure</h5>
                    <p className="text-xs text-white/40">Cities are increasingly concerned about traffic impact.</p>
                  </div>
                  <div className="p-6 rounded-2xl bg-white/5 border border-white/10">
                    <Zap className="w-6 h-6 text-emerald-400 mb-4" />
                    <h5 className="font-medium mb-2">MaaS Shift</h5>
                    <p className="text-xs text-white/40">Rapid consumer shift toward mobility-as-a-service.</p>
                  </div>
                </div>
              </div>

              <div>
                <h2 className="text-4xl font-light tracking-tight mb-8">Go-to-Market</h2>
                <div className="space-y-4">
                  <div className="p-6 rounded-2xl bg-emerald-500/5 border border-emerald-500/20 flex items-center gap-6">
                    <div className="w-12 h-12 rounded-xl bg-emerald-500/10 flex items-center justify-center text-emerald-400 font-bold">01</div>
                    <div>
                      <h5 className="font-medium">Campus Deployment</h5>
                      <p className="text-xs text-white/40">Example: UC Davis. Concentrated patterns, lower regulatory barriers.</p>
                    </div>
                  </div>
                  <div className="p-6 rounded-2xl bg-white/5 border border-white/10 flex items-center gap-6 opacity-60">
                    <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center text-white/40 font-bold">02</div>
                    <div>
                      <h5 className="font-medium">Enterprise Commuting</h5>
                      <p className="text-xs text-white/40">Corporate partnerships for reliable workforce mobility.</p>
                    </div>
                  </div>
                  <div className="p-6 rounded-2xl bg-white/5 border border-white/10 flex items-center gap-6 opacity-40">
                    <div className="w-12 h-12 rounded-xl bg-white/5 flex items-center justify-center text-white/40 font-bold">03</div>
                    <div>
                      <h5 className="font-medium">City-Wide Integration</h5>
                      <p className="text-xs text-white/40">Full orchestration with autonomous fleet operators.</p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>
      </main>

      <footer className="py-12 px-6 border-t border-white/5 text-center">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center justify-center gap-2 mb-6">
            <div className="w-8 h-8 flex items-center justify-center overflow-hidden">
              <img 
                src="https://storage.googleapis.com/static-content-00/39316664-964d-4518-868e-90924962657e.png" 
                alt="RoamingOS Logo"
                className="w-full h-full object-contain"
                style={{ 
                  filter: 'invert(51%) sepia(93%) saturate(1353%) hue-rotate(125deg) brightness(96%) contrast(101%)' 
                }}
                referrerPolicy="no-referrer"
                onError={(e) => {
                  e.currentTarget.style.display = 'none';
                  const parent = e.currentTarget.parentElement;
                  if (parent) {
                    parent.innerHTML = '<div class="w-6 h-6 bg-emerald-500 rounded-full flex items-center justify-center"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="black" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-car"><path d="M19 17h2c.6 0 1-.4 1-1v-3c0-.9-.7-1.7-1.5-1.9C18.7 10.6 16 10 16 10s-1.3-1.4-2.2-2.3c-.5-.4-1.1-.7-1.8-.7H5c-.6 0-1.1.4-1.4.9l-1.4 2.9A3.7 3.7 0 0 0 2 12v4c0 .6.4 1 1 1h2"/><circle cx="7" cy="17" r="2"/><path d="M9 17h6"/><circle cx="17" cy="17" r="2"/></svg></div>';
                  }
                }}
              />
            </div>
            <span className="text-lg font-semibold tracking-tight">RoamingOS</span>
          </div>
          <p className="text-white/20 text-sm">
            © 2026 RoamingOS Autonomous Coordination. Built with Gemini Veo 3.1.
          </p>
        </div>
      </footer>
    </div>
  );
}
