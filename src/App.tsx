/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect, useRef } from 'react';
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
        title: 'Prompt 1.1 — Demand Synchronization & Subscription Activation',
        description: 'At the start of the day, RoamingOS activates subscription commute schedules and aligns fleet positioning with predicted travel demand.',
        prompt: 'At the start of the day, RoamingOS activates subscription commute schedules and aligns fleet positioning with predicted travel demand. Vehicles are pre-dispatched to residential clusters to minimize wait times while maintaining system-wide balance.',
        imageSrc: '/phase1-1.1.png'
      },
      {
        id: '1.2',
        title: 'Prompt 1.2 — AI-Driven Pickup Coordination',
        description: 'Using real-time demand signals, the system dynamically adjusts pickup sequences and routing paths.',
        prompt: 'Using real-time demand signals, the system dynamically adjusts pickup sequences and routing paths. The balancing engine ensures high vehicle occupancy and efficient corridor usage, enabling low-cost subscription rides during peak periods.',
        imageSrc: '/phase1-1.2.png'
      },
      {
        id: '1.3',
        title: 'Prompt 1.3 — Flow Stabilization Through Coordinated Movement',
        description: 'RoamingOS continuously optimizes spacing and speed profiles across vehicles, allowing fleets to move in coordinated patterns that reduce congestion volatility and improve throughput across major routes.',
        prompt: 'RoamingOS continuously optimizes spacing and speed profiles across vehicles, allowing fleets to move in coordinated patterns that reduce congestion volatility and improve throughput across major routes.',
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
        title: 'Prompt 2.1 — Dynamic Mode Switching',
        description: 'As peak demand subsides, the system transitions vehicles from scheduled subscription routes to flexible on-demand service.',
        prompt: 'As peak demand subsides, the system transitions vehicles from scheduled subscription routes to flexible on-demand service. AI balancing ensures fleet supply aligns with real-time mobility needs across the city.',
        imageSrc: '/phase2-2.1.png'
      },
      {
        id: '2.2',
        title: 'Prompt 2.2 — Continuous Demand-Supply Optimization',
        description: 'RoamingOS monitors trip requests and traffic conditions, redistributing vehicles to maintain coverage while preventing oversupply.',
        prompt: 'RoamingOS monitors trip requests and traffic conditions, redistributing vehicles to maintain coverage while preventing oversupply. This balancing layer maximizes utilization and keeps operational costs low.',
        imageSrc: '/phase2-2.2.png'
      },
      {
        id: '2.3',
        title: 'Prompt 2.3 — Energy & Maintenance Orchestration',
        description: 'Charging and servicing are scheduled within low-demand windows through predictive optimization, ensuring readiness without reducing service availability.',
        prompt: 'Charging and servicing are scheduled within low-demand windows through predictive optimization, ensuring readiness without reducing service availability.',
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
        title: 'Prompt 3.1 — Subscription Commute Re-Alignment',
        description: 'The system anticipates evening return patterns and reactivates subscription commute routes, repositioning vehicles near workplaces and transit hubs to support predictable, low-cost return trips.',
        prompt: 'The system anticipates evening return patterns and reactivates subscription commute routes, repositioning vehicles near workplaces and transit hubs to support predictable, low-cost return trips.',
        imageSrc: '/phase3-3.1.png'
      },
      {
        id: '3.2',
        title: 'Prompt 3.2 — Coordinated Departure Balancing',
        description: 'AI scheduling staggers departures and optimizes routing across the network, preventing localized surges while maintaining high fleet efficiency.',
        prompt: 'AI scheduling staggers departures and optimizes routing across the network, preventing localized surges while maintaining high fleet efficiency.',
        imageSrc: '/phase3-3.2.png'
      },
      {
        id: '3.3',
        title: 'Prompt 3.3 — Distributed Demand Absorption',
        description: 'Vehicles disperse across neighborhoods using adaptive routing logic, ensuring smooth drop-off flows and maintaining stable traffic conditions.',
        prompt: 'Vehicles disperse across neighborhoods using adaptive routing logic, ensuring smooth drop-off flows and maintaining stable traffic conditions.',
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
        title: 'Prompt 4.1 — Charging, Maintenance & Fleet Reset',
        description: 'During off-peak hours, RoamingOS dynamically schedules charging, cleaning, and preventive maintenance across the fleet based on next-day demand forecasts.',
        prompt: 'During off-peak hours, RoamingOS dynamically schedules charging, cleaning, and preventive maintenance across the fleet based on next-day demand forecasts.\n\nThis ensures vehicles return to peak periods fully prepared while maintaining optimal availability and operational reliability.',
        imageSrc: '/phase4-4.1.png'
      },
      {
        id: '4.2',
        title: 'Prompt 4.2 — Night Mobility, Airport Transfers & Light Logistics',
        description: 'A portion of the fleet remains active overnight, supporting reservation-based airport transfers, low-cost urban rides, and small-scale cargo delivery.',
        prompt: 'A portion of the fleet remains active overnight, supporting reservation-based airport transfers, low-cost urban rides, and small-scale cargo delivery.\n\nThis multi-role deployment maximizes asset utilization, stabilizes fleet economics, and keeps the system continuously responsive.',
        imageSrc: '/phase4-4.2.png'
      }
    ]
  }
];

// --- Components ---

export default function App() {
  const [selectedScene, setSelectedScene] = useState<Scene | null>(null);
  const resolvePublicPath = (assetPath: string) =>
    `${import.meta.env.BASE_URL}${assetPath.replace(/^\/+/, '')}`;

  return (
    <div className="min-h-screen bg-[#050505] text-white font-sans selection:bg-emerald-500/30">
      {/* Navigation */}
      <nav className="fixed top-0 w-full z-50 border-b border-white/5 bg-black/50 backdrop-blur-md">
        <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
          <a href="#vision" className="flex items-center gap-2">
            <img 
              src={resolvePublicPath('/site-logo.svg')}
              alt="RoamingOS"
              className="h-14 md:h-16 w-auto object-contain"
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
                  const selectedSceneInPhase =
                    selectedScene && selectedScene.id.startsWith(`${phaseNumber}.`)
                      ? selectedScene
                      : null;

                  return (
                    <div 
                      key={phaseIdx} 
                      className={cn(
                        "space-y-4",
                        selectedSceneInPhase && "md:grid md:grid-cols-[minmax(0,1.1fr)_minmax(0,1.4fr)] md:gap-10 md:space-y-0"
                      )}
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
                                selectedScene?.id === scene.id 
                                  ? "bg-white text-black border-white" 
                                  : "bg-transparent border-white/10 hover:border-white/30"
                              )}
                            >
                              <div className="flex items-start gap-3">
                                {scene.imageSrc && (
                                  <img
                                    src={resolvePublicPath(scene.imageSrc)}
                                    alt={`${scene.title} thumbnail`}
                                    className="w-20 h-14 rounded-lg object-cover flex-shrink-0 border border-black/10"
                                  />
                                )}
                                <div className="min-w-0 flex-1">
                                  <div className="flex justify-between items-center mb-1 gap-2">
                                    <span className="text-base font-medium leading-tight">{scene.title}</span>
                                    {selectedScene?.id === scene.id && <ChevronRight className="w-4 h-4 flex-shrink-0" />}
                                  </div>
                                  <p className={cn(
                                    "text-xs line-clamp-2",
                                    selectedScene?.id === scene.id ? "text-black/60" : "text-white/40"
                                  )}>
                                    {scene.description}
                                  </p>
                                </div>
                              </div>
                            </button>
                          ))}
                        </div>
                      </div>

                      {selectedSceneInPhase && (
                        <div className="mt-6 md:mt-0 relative">
                          <div className="w-full rounded-3xl bg-white/5 border border-white/10 overflow-hidden flex flex-col relative shadow-2xl">
                            <div className="w-full aspect-video flex-shrink-0 overflow-hidden rounded-t-3xl">
                              <img
                                src={resolvePublicPath(
                                  selectedSceneInPhase.imageSrc ??
                                  `/phase${selectedSceneInPhase.id.split('.')[0]}-${selectedSceneInPhase.id}.png`
                                )}
                                alt={selectedSceneInPhase.title}
                                className="w-full h-full object-cover"
                              />
                            </div>
                            <div className="p-5 border-t border-white/10 bg-white/5">
                              <h3 className="text-xl font-medium text-white mb-2">{selectedSceneInPhase.title}</h3>
                              <p className="text-sm text-white/70 mb-2">{selectedSceneInPhase.description}</p>
                              <p className="text-sm text-white/50 italic whitespace-pre-line">"{selectedSceneInPhase.prompt}"</p>
                            </div>
                          </div>

                          {/* Decorative Elements */}
                          <div className="absolute -bottom-6 -right-6 w-32 h-32 bg-emerald-500/20 blur-3xl rounded-full" />
                          <div className="absolute -top-6 -left-6 w-32 h-32 bg-blue-500/20 blur-3xl rounded-full" />
                        </div>
                      )}
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
                    { phase: "Phase 2", title: "MVP & Campus Pilot", status: "" },
                    { phase: "Phase 3", title: "Enterprise Partnerships", status: "" },
                    { phase: "Phase 4", title: "City-Level Orchestration", status: "" }
                  ].map((item, i) => (
                    <div key={i} className="p-4 rounded-xl bg-white/5 border border-white/10 flex items-center justify-between">
                      <div>
                        <span className="text-[10px] uppercase tracking-widest text-emerald-400 font-bold">{item.phase}</span>
                        <h5 className="font-medium text-sm">{item.title}</h5>
                      </div>
                      <span className="min-w-[96px] text-right text-xs text-white/20">
                        {item.status || "\u00a0"}
                      </span>
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
                      src={resolvePublicPath('/mit-logo.svg')} 
                      alt="MIT" 
                      className="h-full w-auto object-contain"
                    />
                  </div>
                </div>
                {/* 右：Berkeley */}
                <div className="flex flex-col items-center gap-3">
                  <div className="h-24 w-32 px-4 py-3 rounded-xl bg-white flex items-center justify-center shadow-lg transform hover:scale-105 transition-transform overflow-hidden">
                    <img 
                      src={resolvePublicPath('/berkeley.png')} 
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
            <img
              src={resolvePublicPath('/site-logo.svg')}
              alt="RoamingOS"
              className="h-14 md:h-16 w-auto object-contain"
            />
            <span className="text-lg font-semibold tracking-tight">RoamingOS</span>
          </div>
          <p className="text-white/20 text-sm">
            © 2026 RoamingOS Autonomous Coordination.
          </p>
        </div>
      </footer>
    </div>
  );
}
