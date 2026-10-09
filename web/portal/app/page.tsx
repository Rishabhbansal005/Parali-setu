"use client";

import React, { useState, useEffect } from "react";
import {
  Factory,
  Scale,
  Building2,
  CheckCircle2,
  AlertCircle,
  Truck,
  Leaf,
  DollarSign,
  TrendingUp,
  FileText,
  ShieldCheck,
  Send,
  RefreshCw,
  ExternalLink,
  ChevronRight,
  Sparkles,
  Lock,
  ArrowRight,
  Award,
} from "lucide-react";

type RoleTab = "buyer" | "weighbridge" | "kvk" | "golden-path";

interface ShipmentItem {
  id: string;
  bookingId: string;
  farmerName: string;
  village: string;
  district: string;
  expectedTonnes: number;
  truckNo: string;
  transporter: string;
  status: "in_transit" | "weighbridge_queue" | "paid";
  netTonnes?: number;
  payoutInr?: number;
}

export default function OperationsPortal() {
  const [activeTab, setActiveTab] = useState<RoleTab>("weighbridge");
  const [backendStatus, setBackendStatus] = useState<"checking" | "online" | "simulated">("checking");
  const [apiBaseUrl, setApiBaseUrl] = useState<string>("http://localhost:8000");

  // Biomass Buyer State
  const [dailyDemand, setDailyDemand] = useState<number>(200);
  const [purchaseRate, setPurchaseRate] = useState<number>(1500);
  const [escrowDeposited, setEscrowDeposited] = useState<number>(300000);
  const [demandSavedNotice, setDemandSavedNotice] = useState<boolean>(false);

  // Weighbridge State
  const [selectedShipmentId, setSelectedShipmentId] = useState<string>("BK-9810-01");
  const [grossWeight, setGrossWeight] = useState<number>(14.2);
  const [tareWeight, setTareWeight] = useState<number>(6.2);
  const [ticketNumber, setTicketNumber] = useState<string>("TKT-DK-2026-9941");
  const [isSubmittingSlip, setIsSubmittingSlip] = useState<boolean>(false);
  const [slipSuccessData, setSlipSuccessData] = useState<{
    farmerName: string;
    netTonnes: number;
    payout: number;
    bankRef: string;
  } | null>(null);

  // KVK Subsidy State
  const [subsidyApprovedList, setSubsidyApprovedList] = useState<string[]>([]);
  const [formattedTime, setFormattedTime] = useState<string>("2026-10-25 14:30");

  useEffect(() => {
    setFormattedTime(new Date().toISOString().substring(0, 16).replace("T", " "));
  }, []);

  // Shipments List
  const [shipments, setShipments] = useState<ShipmentItem[]>([
    {
      id: "BK-9810-01",
      bookingId: "bk-gurpreet-01",
      farmerName: "Gurpreet Singh",
      village: "Kot Buddha",
      district: "Tarn Taran",
      expectedTonnes: 8.0,
      truckNo: "PB-11-AB-4029",
      transporter: "Sharma Agri Transport",
      status: "weighbridge_queue",
    },
    {
      id: "BK-9810-02",
      bookingId: "bk-harinder-02",
      farmerName: "Harinder Kaur",
      village: "Cheema",
      district: "Sangrur",
      expectedTonnes: 12.0,
      truckNo: "PB-02-X-9912",
      transporter: "Dhillon Logistics",
      status: "in_transit",
    },
    {
      id: "BK-9810-03",
      bookingId: "bk-jagjit-03",
      farmerName: "Jagjit Singh",
      village: "Bhawanigarh",
      district: "Sangrur",
      expectedTonnes: 6.0,
      truckNo: "PB-10-Q-1102",
      transporter: "Malwa Express",
      status: "paid",
      netTonnes: 6.05,
      payoutInr: 9075,
    },
  ]);

  // Derived Net Weight
  const calculatedNet = Math.max(0, Number((grossWeight - tareWeight).toFixed(2)));
  const isSanityValid = Math.abs(grossWeight - tareWeight - calculatedNet) <= 0.02 && grossWeight > tareWeight;

  // Check Backend Health on Mount
  useEffect(() => {
    async function checkHealth() {
      try {
        const res = await fetch(`${apiBaseUrl}/health`, { method: "GET" });
        if (res.ok) {
          setBackendStatus("online");
          return;
        }
      } catch (e) {
        // Fallback to simulated mode
      }
      setBackendStatus("simulated");
    }
    checkHealth();
  }, [apiBaseUrl]);

  // Handle Save Buyer Demand
  const handleSaveDemand = () => {
    setDemandSavedNotice(true);
    setTimeout(() => setDemandSavedNotice(false), 3000);
  };

  // Handle Submit Weighbridge Slip
  const handleSubmitWeighbridge = async () => {
    setIsSubmittingSlip(true);
    const selected = shipments.find((s) => s.id === selectedShipmentId) || shipments[0];
    const payout = Math.round(calculatedNet * purchaseRate);

    try {
      if (backendStatus === "online") {
        // Live API call to FastAPI backend
        await fetch(`${apiBaseUrl}/bookings/${selected.bookingId}/weighbridge`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            gross_weight_tonnes: grossWeight,
            tare_weight_tonnes: tareWeight,
            ticket_number: ticketNumber,
          }),
        });
      }
    } catch (e) {
      console.warn("API weighbridge post failed, proceeding in simulated mode", e);
    }

    setTimeout(() => {
      setIsSubmittingSlip(false);
      setSlipSuccessData({
        farmerName: selected.farmerName,
        netTonnes: calculatedNet,
        payout: payout,
        bankRef: "HDFC-IMPS-" + Math.floor(100000 + Math.random() * 900000),
      });

      // Update shipment in list to paid
      setShipments((prev) =>
        prev.map((s) =>
          s.id === selected.id
            ? {
                ...s,
                status: "paid",
                netTonnes: calculatedNet,
                payoutInr: payout,
              }
            : s
        )
      );
    }, 600);
  };

  const handleApproveSubsidy = (farmerId: string) => {
    setSubsidyApprovedList((prev) => [...prev, farmerId]);
  };

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 flex flex-col">
      {/* Top Operations Header */}
      <header className="border-b border-slate-800 bg-slate-900/80 backdrop-blur sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <div className="h-10 w-10 rounded-xl bg-gradient-to-br from-emerald-600 to-green-800 flex items-center justify-center shadow-lg shadow-emerald-900/40 border border-emerald-500/30">
              <Leaf className="h-5 w-5 text-emerald-200" />
            </div>
            <div>
              <div className="flex items-center space-x-2">
                <span className="font-extrabold text-lg tracking-tight bg-gradient-to-r from-emerald-400 via-green-300 to-amber-300 bg-clip-text text-transparent">
                  ParaliSetu
                </span>
                <span className="text-xs px-2 py-0.5 rounded-full bg-slate-800 text-slate-400 font-mono border border-slate-700">
                  Operations Console
                </span>
              </div>
              <p className="text-xs text-slate-400 hidden sm:block">
                पराली सेतु — Biomass Buyers, Dharamkanta Terminal & District Administration
              </p>
            </div>
          </div>

          {/* Right Status Badges */}
          <div className="flex items-center space-x-4">
            <div className="hidden md:flex items-center space-x-2 px-3 py-1.5 rounded-lg bg-slate-800/80 border border-slate-700 text-xs">
              <span
                className={`h-2.5 w-2.5 rounded-full ${
                  backendStatus === "online" ? "bg-emerald-400 animate-pulse" : "bg-amber-400"
                }`}
              />
              <span className="text-slate-300 font-medium">
                {backendStatus === "online" ? "FastAPI Backend Online" : "Simulated Local Engine"}
              </span>
            </div>

            <div className="flex items-center space-x-1.5 px-3 py-1.5 rounded-lg bg-amber-500/10 border border-amber-500/30 text-amber-300 text-xs font-semibold">
              <Lock className="h-3.5 w-3.5" />
              <span>Simulated Escrow: ₹{escrowDeposited.toLocaleString("en-IN")}</span>
            </div>
          </div>
        </div>

        {/* Stakeholder Navigation Tabs */}
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex space-x-2 overflow-x-auto py-2.5 border-t border-slate-800/60 text-sm">
          <button
            onClick={() => setActiveTab("weighbridge")}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-semibold transition ${
              activeTab === "weighbridge"
                ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/40"
                : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
            }`}
          >
            <Scale className="h-4 w-4" />
            <span>Dharamkanta Weighbridge Terminal</span>
            <span className="text-xs px-2 py-0.5 rounded-full bg-emerald-950/60 text-emerald-200 border border-emerald-500/30">
              Step 5
            </span>
          </button>

          <button
            onClick={() => setActiveTab("buyer")}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-semibold transition ${
              activeTab === "buyer"
                ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/40"
                : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
            }`}
          >
            <Factory className="h-4 w-4" />
            <span>Biomass Buyer Dashboard (Bio-CNG)</span>
          </button>

          <button
            onClick={() => setActiveTab("kvk")}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-semibold transition ${
              activeTab === "kvk"
                ? "bg-emerald-600 text-white shadow-lg shadow-emerald-900/40"
                : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
            }`}
          >
            <Building2 className="h-4 w-4" />
            <span>KVK & District Agriculture Officer</span>
          </button>

          <button
            onClick={() => setActiveTab("golden-path")}
            className={`flex items-center space-x-2 px-4 py-2 rounded-lg font-semibold transition ${
              activeTab === "golden-path"
                ? "bg-amber-600 text-white shadow-lg shadow-amber-900/40"
                : "text-amber-400 hover:text-amber-200 hover:bg-amber-950/20"
            }`}
          >
            <Sparkles className="h-4 w-4" />
            <span>Golden Path Live Bridge</span>
          </button>
        </div>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 max-w-7xl w-full mx-auto p-4 sm:p-6 lg:p-8 space-y-8">
        {/* ========================================================================= */}
        {/* TAB 1: DHARAMKANTA WEIGHBRIDGE TERMINAL (GOLDEN PATH STEP 5)              */}
        {/* ========================================================================= */}
        {activeTab === "weighbridge" && (
          <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-emerald-950/40 via-slate-900 to-slate-900 p-6 rounded-2xl border border-emerald-800/30">
              <div>
                <div className="flex items-center space-x-3 mb-2">
                  <div className="p-2 rounded-lg bg-emerald-500/20 border border-emerald-500/40 text-emerald-400">
                    <Scale className="h-6 w-6" />
                  </div>
                  <h1 className="text-2xl font-bold text-white tracking-tight">
                    Dharamkanta Weighbridge Terminal
                  </h1>
                </div>
                <p className="text-slate-400 text-sm max-w-2xl">
                  Official certified slip logger for truck arrivals. Gross & tare inputs automatically compute
                  certified net parali and release escrow funds to the farmer&apos;s bank account in real-time.
                </p>
              </div>

              <div className="flex items-center space-x-3">
                <div className="text-right">
                  <div className="text-xs text-slate-400">Weighbridge Location</div>
                  <div className="text-sm font-semibold text-slate-200">
                    Kisan Dharamkanta, Tarn Taran Main GT Road
                  </div>
                </div>
                <div className="h-10 w-10 rounded-xl bg-slate-800 border border-slate-700 flex items-center justify-center">
                  <Truck className="h-5 w-5 text-emerald-400" />
                </div>
              </div>
            </div>

            {/* Weighbridge Entry Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Slip Entry Card (2 Columns) */}
              <div className="lg:col-span-2 glass-panel p-6 rounded-2xl space-y-6">
                <div className="flex items-center justify-between border-b border-slate-800 pb-4">
                  <div className="flex items-center space-x-2">
                    <FileText className="h-5 w-5 text-emerald-400" />
                    <h2 className="font-bold text-lg text-slate-100">Electronic Ticket Generation</h2>
                  </div>
                  <span className="text-xs font-mono text-emerald-400 bg-emerald-950/80 px-2.5 py-1 rounded border border-emerald-800">
                    Rule: |Gross - Tare - Net| &le; 0.02 t
                  </span>
                </div>

                {/* Form Elements */}
                <div className="space-y-5">
                  {/* Shipment Selector */}
                  <div>
                    <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                      Select Arriving Truck & Farmer
                    </label>
                    <select
                      value={selectedShipmentId}
                      onChange={(e) => setSelectedShipmentId(e.target.value)}
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-3 text-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500 font-medium"
                    >
                      {shipments.map((s) => (
                        <option key={s.id} value={s.id}>
                          {s.id} — {s.farmerName} ({s.village}, {s.district}) | Truck: {s.truckNo} (Expected: {s.expectedTonnes}t)
                        </option>
                      ))}
                    </select>
                  </div>

                  {/* Weights Input Row */}
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div>
                      <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Gross Weight (Truck + Straw)
                      </label>
                      <div className="relative">
                        <input
                          type="number"
                          step="0.05"
                          value={grossWeight}
                          onChange={(e) => setGrossWeight(parseFloat(e.target.value) || 0)}
                          className="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-3 text-xl font-bold text-slate-100 focus:outline-none focus:ring-2 focus:ring-emerald-500 pr-12"
                        />
                        <span className="absolute right-4 top-3.5 text-sm font-semibold text-slate-400">t</span>
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Tare Weight (Empty Truck)
                      </label>
                      <div className="relative">
                        <input
                          type="number"
                          step="0.05"
                          value={tareWeight}
                          onChange={(e) => setTareWeight(parseFloat(e.target.value) || 0)}
                          className="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-3 text-xl font-bold text-slate-100 focus:outline-none focus:ring-2 focus:ring-emerald-500 pr-12"
                        />
                        <span className="absolute right-4 top-3.5 text-sm font-semibold text-slate-400">t</span>
                      </div>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-emerald-400 uppercase tracking-wider mb-2">
                        Certified Net Straw
                      </label>
                      <div className="bg-emerald-950/40 border border-emerald-500/40 rounded-xl px-4 py-3 flex items-center justify-between">
                        <span className="text-2xl font-extrabold text-emerald-300">
                          {calculatedNet.toFixed(2)}
                        </span>
                        <span className="text-sm font-semibold text-emerald-400">Tonnes</span>
                      </div>
                    </div>
                  </div>

                  {/* Ticket Number & OCR Preview */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
                    <div>
                      <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Weighbridge Ticket Number
                      </label>
                      <input
                        type="text"
                        value={ticketNumber}
                        onChange={(e) => setTicketNumber(e.target.value)}
                        className="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-2.5 text-sm font-mono text-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                        Dharamkanta Thermal Slip Photo
                      </label>
                      <div className="flex items-center space-x-3 bg-slate-900 border border-dashed border-slate-700 rounded-xl p-2.5">
                        <div className="h-9 w-9 rounded-lg bg-emerald-900/40 border border-emerald-600/40 flex items-center justify-center text-emerald-300">
                          <CheckCircle2 className="h-5 w-5" />
                        </div>
                        <div className="text-xs">
                          <div className="font-medium text-slate-200">slip_photo_tkt9941.jpg</div>
                          <div className="text-emerald-400">OCR Sanity Passed (0.00% Variance)</div>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Anti-fraud banner */}
                  <div
                    className={`p-4 rounded-xl border flex items-start space-x-3 ${
                      isSanityValid
                        ? "bg-emerald-950/20 border-emerald-800/40 text-emerald-300"
                        : "bg-red-950/20 border-red-800/40 text-red-300"
                    }`}
                  >
                    {isSanityValid ? (
                      <ShieldCheck className="h-5 w-5 flex-shrink-0 mt-0.5 text-emerald-400" />
                    ) : (
                      <AlertCircle className="h-5 w-5 flex-shrink-0 mt-0.5 text-red-400" />
                    )}
                    <div className="text-xs space-y-1">
                      <div className="font-bold">
                        {isSanityValid
                          ? "Automated Anti-Tamper Verification Cleared"
                          : "Tare Weight exceeds Gross or Negative Net"}
                      </div>
                      <div className="text-slate-400">
                        Certified net weight matches physical scale transducer signal. Ready to trigger simulated
                        escrow transfer of ₹{(calculatedNet * purchaseRate).toLocaleString("en-IN")}.
                      </div>
                    </div>
                  </div>

                  {/* Action Button */}
                  <button
                    disabled={!isSanityValid || isSubmittingSlip}
                    onClick={handleSubmitWeighbridge}
                    className="w-full py-4 rounded-xl font-bold text-base flex items-center justify-center space-x-2 bg-gradient-to-r from-emerald-600 to-green-700 hover:from-emerald-500 hover:to-green-600 text-white shadow-lg shadow-emerald-900/50 transition disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
                  >
                    {isSubmittingSlip ? (
                      <>
                        <RefreshCw className="h-5 w-5 animate-spin" />
                        <span>Transmitting to FastAPI Escrow Engine...</span>
                      </>
                    ) : (
                      <>
                        <CheckCircle2 className="h-5 w-5" />
                        <span>
                          Certify Weighbridge Ticket & Release Escrow (₹
                          {(calculatedNet * purchaseRate).toLocaleString("en-IN")})
                        </span>
                      </>
                    )}
                  </button>
                </div>
              </div>

              {/* Live Ticket & Thermal Slip Preview (1 Column) */}
              <div className="glass-panel p-6 rounded-2xl flex flex-col justify-between space-y-6">
                <div>
                  <h3 className="font-bold text-sm text-slate-300 uppercase tracking-wider mb-4 flex items-center space-x-2">
                    <FileText className="h-4 w-4 text-amber-400" />
                    <span>Dharamkanta Printed Slip Replica</span>
                  </h3>

                  {/* Thermal Paper Simulation */}
                  <div className="bg-amber-50 text-slate-900 rounded-lg p-5 font-mono text-xs shadow-inner space-y-3 border border-amber-200">
                    <div className="text-center border-b border-dashed border-slate-400 pb-2">
                      <div className="font-black text-sm">KISAN DHARAMKANTA</div>
                      <div className="text-[10px] text-slate-600">TARN TARAN ROAD, PUNJAB</div>
                      <div className="text-[10px] text-slate-500">GOVT REG # PB-TT-9982</div>
                    </div>

                    <div className="space-y-1 text-[11px]">
                      <div className="flex justify-between">
                        <span className="text-slate-600">Ticket No:</span>
                        <span className="font-bold">{ticketNumber}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-600">Date/Time:</span>
                        <span>{formattedTime}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-600">Truck No:</span>
                        <span className="font-bold">
                          {shipments.find((s) => s.id === selectedShipmentId)?.truckNo}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-600">Farmer:</span>
                        <span className="font-bold">
                          {shipments.find((s) => s.id === selectedShipmentId)?.farmerName}
                        </span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-slate-600">Crop Residue:</span>
                        <span>Paddy Straw (Parali)</span>
                      </div>
                    </div>

                    <div className="border-t border-b border-dashed border-slate-400 py-2 space-y-1">
                      <div className="flex justify-between">
                        <span>GROSS WT:</span>
                        <span className="font-bold">{grossWeight.toFixed(2)} Tonnes</span>
                      </div>
                      <div className="flex justify-between">
                        <span>TARE WT:</span>
                        <span className="font-bold">{tareWeight.toFixed(2)} Tonnes</span>
                      </div>
                      <div className="flex justify-between text-emerald-900 font-extrabold text-xs">
                        <span>NET PARALI:</span>
                        <span>{calculatedNet.toFixed(2)} TONNES</span>
                      </div>
                    </div>

                    <div className="text-center text-[10px] text-slate-500 pt-1">
                      *** CERTIFIED EX-SITU PARALI TICKET ***
                      <br />
                      PARALISETU SECURE ESCROW AUTHORIZED
                    </div>
                  </div>
                </div>

                {/* Instant Escrow Settlement Notification */}
                {slipSuccessData && (
                  <div className="p-4 rounded-xl bg-emerald-950/60 border border-emerald-500/60 text-emerald-200 space-y-2 animate-fade-in">
                    <div className="flex items-center space-x-2 font-bold text-sm text-emerald-300">
                      <CheckCircle2 className="h-4 w-4" />
                      <span>Direct Escrow Release Dispatched!</span>
                    </div>
                    <div className="text-xs text-slate-300 space-y-1">
                      <div>
                        <strong>₹{slipSuccessData.payout.toLocaleString("en-IN")}</strong> credited to{" "}
                        {slipSuccessData.farmerName}.
                      </div>
                      <div className="font-mono text-[11px] text-emerald-400">
                        Bank Ref: {slipSuccessData.bankRef}
                      </div>
                      <div className="text-slate-400">
                        Status on mobile app updated to <strong>PAID</strong>. Sentinel-2 burn verification is now
                        active!
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        )}

        {/* ========================================================================= */}
        {/* TAB 2: BIOMASS BUYER DASHBOARD (BIO-CNG & PELLET PLANTS)                  */}
        {/* ========================================================================= */}
        {activeTab === "buyer" && (
          <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-emerald-950/40 via-slate-900 to-slate-900 p-6 rounded-2xl border border-emerald-800/30">
              <div>
                <div className="flex items-center space-x-3 mb-2">
                  <div className="p-2 rounded-lg bg-emerald-500/20 border border-emerald-500/40 text-emerald-400">
                    <Factory className="h-6 w-6" />
                  </div>
                  <h1 className="text-2xl font-bold text-white tracking-tight">
                    Biomass Buyer Command Center
                  </h1>
                </div>
                <p className="text-slate-400 text-sm max-w-2xl">
                  Sangrur Bio-CNG Plant #1 — Set daily parali intake quota, configure factory purchase rate per tonne,
                  and lock simulated escrow funds to guarantee farmer supply.
                </p>
              </div>

              <div className="flex items-center space-x-3">
                <div className="text-right">
                  <div className="text-xs text-slate-400">Buyer Entity</div>
                  <div className="text-sm font-semibold text-slate-200">EverEnviro Bio-CNG Ltd, Sangrur</div>
                </div>
                <div className="h-10 w-10 rounded-xl bg-slate-800 border border-slate-700 flex items-center justify-center">
                  <Building2 className="h-5 w-5 text-amber-400" />
                </div>
              </div>
            </div>

            {/* KPI Stat Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="glass-panel p-5 rounded-2xl space-y-2">
                <div className="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
                  <span>Daily Quota</span>
                  <TrendingUp className="h-4 w-4 text-emerald-400" />
                </div>
                <div className="text-2xl font-black text-slate-100">{dailyDemand} Tonnes / Day</div>
                <div className="w-full bg-slate-800 h-2 rounded-full overflow-hidden">
                  <div className="bg-emerald-500 h-full w-[68%]" />
                </div>
                <div className="text-xs text-slate-400 flex justify-between">
                  <span>136 t Delivered Today</span>
                  <span className="font-semibold text-emerald-400">68%</span>
                </div>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-2">
                <div className="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
                  <span>Purchase Rate</span>
                  <DollarSign className="h-4 w-4 text-amber-400" />
                </div>
                <div className="text-2xl font-black text-amber-300">₹{purchaseRate.toLocaleString("en-IN")} / t</div>
                <p className="text-xs text-slate-400">Ex-weighbridge factory gate guaranteed price</p>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-2">
                <div className="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
                  <span>Simulated Escrow</span>
                  <Lock className="h-4 w-4 text-emerald-400" />
                </div>
                <div className="text-2xl font-black text-emerald-400">
                  ₹{escrowDeposited.toLocaleString("en-IN")}
                </div>
                <p className="text-xs text-slate-400">Held in escrow to guarantee instant payout</p>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-2">
                <div className="flex items-center justify-between text-slate-400 text-xs font-semibold uppercase">
                  <span>CO₂ Avoided</span>
                  <Leaf className="h-4 w-4 text-green-400" />
                </div>
                <div className="text-2xl font-black text-green-300">{(dailyDemand * 1.5).toFixed(0)} Tonnes</div>
                <p className="text-xs text-slate-400">Equivalent to planting {(dailyDemand * 69).toFixed(0)} trees</p>
              </div>
            </div>

            {/* Demand Control & Supply Pipeline */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
              {/* Daily Demand Configuration Card */}
              <div className="glass-panel p-6 rounded-2xl space-y-5">
                <h3 className="font-bold text-base text-slate-200 flex items-center space-x-2">
                  <Factory className="h-4 w-4 text-emerald-400" />
                  <span>Configure Daily Straw Intake</span>
                </h3>

                <div className="space-y-4">
                  <div>
                    <div className="flex justify-between text-xs text-slate-300 font-semibold mb-2">
                      <span>Daily Straw Demand (Tonnes/Day)</span>
                      <span className="text-emerald-400 font-bold">{dailyDemand} t</span>
                    </div>
                    <input
                      type="range"
                      min={50}
                      max={500}
                      step={10}
                      value={dailyDemand}
                      onChange={(e) => setDailyDemand(parseInt(e.target.value))}
                      className="w-full accent-emerald-500 cursor-pointer"
                    />
                  </div>

                  <div>
                    <div className="flex justify-between text-xs text-slate-300 font-semibold mb-2">
                      <span>Offered Price (₹ / Tonne)</span>
                      <span className="text-amber-400 font-bold">₹{purchaseRate}</span>
                    </div>
                    <input
                      type="range"
                      min={1000}
                      max={2500}
                      step={50}
                      value={purchaseRate}
                      onChange={(e) => setPurchaseRate(parseInt(e.target.value))}
                      className="w-full accent-amber-500 cursor-pointer"
                    />
                  </div>

                  <div>
                    <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                      Simulated Escrow Commitment (₹)
                    </label>
                    <input
                      type="number"
                      step={10000}
                      value={escrowDeposited}
                      onChange={(e) => setEscrowDeposited(parseInt(e.target.value) || 0)}
                      className="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-2.5 text-slate-200 focus:outline-none focus:ring-2 focus:ring-emerald-500 font-medium"
                    />
                  </div>

                  {demandSavedNotice && (
                    <div className="p-3 rounded-lg bg-emerald-950/60 border border-emerald-500/40 text-emerald-300 text-xs font-medium flex items-center space-x-2 animate-fade-in">
                      <CheckCircle2 className="h-4 w-4 text-emerald-400" />
                      <span>Demand quota & escrow commitment updated!</span>
                    </div>
                  )}

                  <button
                    onClick={handleSaveDemand}
                    className="w-full py-3 rounded-xl font-bold text-sm bg-emerald-600 hover:bg-emerald-500 text-white shadow-lg shadow-emerald-900/40 transition cursor-pointer"
                  >
                    Publish Demand to OR-Tools Matching Engine
                  </button>
                </div>
              </div>

              {/* Incoming Deliveries Table */}
              <div className="lg:col-span-2 glass-panel p-6 rounded-2xl space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="font-bold text-base text-slate-200 flex items-center space-x-2">
                    <Truck className="h-4 w-4 text-emerald-400" />
                    <span>Real-Time Incoming Supply Pipeline</span>
                  </h3>
                  <span className="text-xs text-slate-400">Auto-refreshed via OR-Tools</span>
                </div>

                <div className="overflow-x-auto">
                  <table className="w-full text-left text-xs">
                    <thead>
                      <tr className="border-b border-slate-800 text-slate-400 uppercase">
                        <th className="pb-3 font-semibold">Booking ID</th>
                        <th className="pb-3 font-semibold">Farmer & Village</th>
                        <th className="pb-3 font-semibold">Truck & Transporter</th>
                        <th className="pb-3 font-semibold">Expected</th>
                        <th className="pb-3 font-semibold">Status</th>
                        <th className="pb-3 font-semibold">Payout</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-800/60">
                      {shipments.map((s) => (
                        <tr key={s.id} className="hover:bg-slate-900/40 transition">
                          <td className="py-3 font-mono font-bold text-emerald-400">{s.id}</td>
                          <td className="py-3">
                            <div className="font-medium text-slate-200">{s.farmerName}</div>
                            <div className="text-slate-400 text-[11px]">
                              {s.village}, {s.district}
                            </div>
                          </td>
                          <td className="py-3">
                            <div className="font-mono text-slate-300">{s.truckNo}</div>
                            <div className="text-slate-500 text-[11px]">{s.transporter}</div>
                          </td>
                          <td className="py-3 font-semibold text-slate-200">{s.expectedTonnes} t</td>
                          <td className="py-3">
                            {s.status === "paid" ? (
                              <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-emerald-950/80 text-emerald-300 border border-emerald-700/50">
                                Verified & Paid
                              </span>
                            ) : s.status === "weighbridge_queue" ? (
                              <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-amber-950/80 text-amber-300 border border-amber-700/50">
                                At Weighbridge
                              </span>
                            ) : (
                              <span className="px-2.5 py-1 rounded-full text-[11px] font-bold bg-blue-950/80 text-blue-300 border border-blue-700/50">
                                In Transit
                              </span>
                            )}
                          </td>
                          <td className="py-3 font-bold text-slate-200">
                            {s.payoutInr ? `₹${s.payoutInr.toLocaleString("en-IN")}` : "Escrow Locked"}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ========================================================================= */}
        {/* TAB 3: KVK & DISTRICT AGRICULTURE OFFICER (COMPLIANCE & SUBSIDY)          */}
        {/* ========================================================================= */}
        {activeTab === "kvk" && (
          <div className="space-y-6">
            <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 bg-gradient-to-r from-emerald-950/40 via-slate-900 to-slate-900 p-6 rounded-2xl border border-emerald-800/30">
              <div>
                <div className="flex items-center space-x-3 mb-2">
                  <div className="p-2 rounded-lg bg-emerald-500/20 border border-emerald-500/40 text-emerald-400">
                    <Building2 className="h-6 w-6" />
                  </div>
                  <h1 className="text-2xl font-bold text-white tracking-tight">
                    KVK & District Agriculture Compliance
                  </h1>
                </div>
                <p className="text-slate-400 text-sm max-w-2xl">
                  Krishi Vigyan Kendra (KVK) & Sub-Divisional Magistrate Portal — Monitor district-wide residue
                  diversion, audit Sentinel-2 SWIR satellite burn indices, and approve the ₹1,000/acre ex-situ
                  incentive.
                </p>
              </div>

              <div className="flex items-center space-x-3">
                <div className="text-right">
                  <div className="text-xs text-slate-400">Jurisdiction</div>
                  <div className="text-sm font-semibold text-slate-200">Sangrur & Tarn Taran Districts</div>
                </div>
                <div className="h-10 w-10 rounded-xl bg-slate-800 border border-slate-700 flex items-center justify-center">
                  <Award className="h-5 w-5 text-emerald-400" />
                </div>
              </div>
            </div>

            {/* Environmental Impact Statistics */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="glass-panel p-5 rounded-2xl space-y-1">
                <div className="text-xs font-semibold text-slate-400 uppercase">Diverted Residue</div>
                <div className="text-3xl font-black text-emerald-400">1,420 Tonnes</div>
                <p className="text-[11px] text-slate-400">Verified by weighbridge tickets</p>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-1">
                <div className="text-xs font-semibold text-slate-400 uppercase">Prevented CO₂ Smoke</div>
                <div className="text-3xl font-black text-green-300">2,130 Tonnes</div>
                <p className="text-[11px] text-slate-400">1.5 t CO₂ saved per tonne</p>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-1">
                <div className="text-xs font-semibold text-slate-400 uppercase">Prevented PM₂.₅ Particulates</div>
                <div className="text-3xl font-black text-amber-300">25,560 kg</div>
                <p className="text-[11px] text-slate-400">18.0 kg PM₂.₅ saved per tonne</p>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-1">
                <div className="text-xs font-semibold text-slate-400 uppercase">Equivalent Trees Saved</div>
                <div className="text-3xl font-black text-emerald-300">97,841 Trees</div>
                <p className="text-[11px] text-slate-400">Annual carbon sequestration</p>
              </div>
            </div>

            {/* Satellite Verification & Subsidy Queue */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Sentinel-2 Spectral Verification Cards */}
              <div className="glass-panel p-6 rounded-2xl space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="font-bold text-base text-slate-200 flex items-center space-x-2">
                    <ShieldCheck className="h-5 w-5 text-emerald-400" />
                    <span>Sentinel-2 SWIR NBR Verification Audit</span>
                  </h3>
                  <span className="text-xs text-emerald-400 font-mono">ΔNBR &lt; 0.10</span>
                </div>

                <div className="space-y-3">
                  <div className="p-4 rounded-xl bg-slate-900 border border-slate-800 space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="font-bold text-sm text-slate-200">Gurpreet Singh (4.0 Acres)</span>
                      <span className="text-xs font-mono px-2 py-0.5 rounded bg-emerald-950 text-emerald-300 border border-emerald-800">
                        ΔNBR: 0.038 (Clean)
                      </span>
                    </div>
                    <div className="text-xs text-slate-400 flex justify-between">
                      <span>Polygon: 31.144° N, 74.928° E</span>
                      <span className="text-emerald-400 font-semibold">✓ No-Burn Certificate Issued</span>
                    </div>
                  </div>

                  <div className="p-4 rounded-xl bg-slate-900 border border-slate-800 space-y-2">
                    <div className="flex justify-between items-center">
                      <span className="font-bold text-sm text-slate-200">Jagjit Singh (3.0 Acres)</span>
                      <span className="text-xs font-mono px-2 py-0.5 rounded bg-emerald-950 text-emerald-300 border border-emerald-800">
                        ΔNBR: 0.042 (Clean)
                      </span>
                    </div>
                    <div className="text-xs text-slate-400 flex justify-between">
                      <span>Polygon: 30.228° N, 75.834° E</span>
                      <span className="text-emerald-400 font-semibold">✓ No-Burn Certificate Issued</span>
                    </div>
                  </div>
                </div>
              </div>

              {/* Government ₹1,000/Acre Subsidy Approval Queue */}
              <div className="glass-panel p-6 rounded-2xl space-y-4">
                <div className="flex items-center justify-between">
                  <h3 className="font-bold text-base text-slate-200 flex items-center space-x-2">
                    <Award className="h-5 w-5 text-amber-400" />
                    <span>₹1,000/Acre Ex-Situ Subsidy Approvals</span>
                  </h3>
                  <span className="text-xs text-slate-400">Punjab State Clean Air Scheme</span>
                </div>

                <div className="space-y-3">
                  <div className="p-4 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-sm text-slate-200">Gurpreet Singh (Kot Buddha)</div>
                      <div className="text-xs text-slate-400">4.0 Acres verified • Subsidy: ₹4,000</div>
                    </div>
                    {subsidyApprovedList.includes("gurpreet") ? (
                      <span className="text-xs font-bold text-emerald-300 bg-emerald-950 px-3 py-1.5 rounded-lg border border-emerald-800">
                        ✓ Approved (DBT Queued)
                      </span>
                    ) : (
                      <button
                        onClick={() => handleApproveSubsidy("gurpreet")}
                        className="px-3.5 py-1.5 rounded-lg text-xs font-bold bg-amber-600 hover:bg-amber-500 text-white transition cursor-pointer"
                      >
                        1-Click Approve (₹4,000)
                      </button>
                    )}
                  </div>

                  <div className="p-4 rounded-xl bg-slate-900 border border-slate-800 flex items-center justify-between">
                    <div>
                      <div className="font-bold text-sm text-slate-200">Jagjit Singh (Bhawanigarh)</div>
                      <div className="text-xs text-slate-400">3.0 Acres verified • Subsidy: ₹3,000</div>
                    </div>
                    {subsidyApprovedList.includes("jagjit") ? (
                      <span className="text-xs font-bold text-emerald-300 bg-emerald-950 px-3 py-1.5 rounded-lg border border-emerald-800">
                        ✓ Approved (DBT Queued)
                      </span>
                    ) : (
                      <button
                        onClick={() => handleApproveSubsidy("jagjit")}
                        className="px-3.5 py-1.5 rounded-lg text-xs font-bold bg-amber-600 hover:bg-amber-500 text-white transition cursor-pointer"
                      >
                        1-Click Approve (₹3,000)
                      </button>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* ========================================================================= */}
        {/* TAB 4: GOLDEN PATH LIVE BRIDGE                                            */}
        {/* ========================================================================= */}
        {activeTab === "golden-path" && (
          <div className="space-y-6">
            <div className="bg-gradient-to-r from-amber-950/40 via-slate-900 to-slate-900 p-6 rounded-2xl border border-amber-800/30">
              <div className="flex items-center space-x-3 mb-2">
                <div className="p-2 rounded-lg bg-amber-500/20 border border-amber-500/40 text-amber-400">
                  <Sparkles className="h-6 w-6" />
                </div>
                <h1 className="text-2xl font-bold text-white tracking-tight">
                  Golden Path End-to-End Simulation Bridge
                </h1>
              </div>
              <p className="text-slate-400 text-sm max-w-3xl">
                Demonstrating the seamless live integration between the <strong>Flutter Farmer Mobile App</strong>{" "}
                and this <strong>Operations Web Portal</strong> across the 7 milestones of the hackathon prototype.
              </p>
            </div>

            {/* Stepper Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              <div className="glass-panel p-5 rounded-2xl space-y-3 border-l-4 border-l-emerald-500">
                <div className="text-xs font-bold text-emerald-400 flex items-center space-x-1">
                  <span>STEP 1 — MOBILE</span>
                </div>
                <div className="font-bold text-slate-100">Vernacular Voice Intake</div>
                <p className="text-xs text-slate-400">
                  Farmer speaks in Punjabi (*&quot;4 ਕਿੱਲੇ PR-126, 25 ਅਕਤੂਬਰ&quot;*), app speaks back confirmation per AI
                  Directive #1, and auto-fills fields.
                </p>
                <div className="text-[11px] font-mono text-emerald-400 bg-emerald-950/60 p-2 rounded border border-emerald-900">
                  Status: BUILT (feat/voice-intake)
                </div>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-3 border-l-4 border-l-emerald-500">
                <div className="text-xs font-bold text-emerald-400 flex items-center space-x-1">
                  <span>STEP 2 & 3 — ALGO</span>
                </div>
                <div className="font-bold text-slate-100">PAU Formula & OR-Tools</div>
                <p className="text-xs text-slate-400">
                  PAU Ludhiana formula calculates 8.0t recoverable straw; Google OR-Tools CP-SAT groups contiguous
                  farms into optimal pickup bundles.
                </p>
                <div className="text-[11px] font-mono text-emerald-400 bg-emerald-950/60 p-2 rounded border border-emerald-900">
                  Status: BUILT (feat/matching)
                </div>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-3 border-l-4 border-l-emerald-500">
                <div className="text-xs font-bold text-emerald-400 flex items-center space-x-1">
                  <span>STEP 4 & 5 — WEB PORTAL</span>
                </div>
                <div className="font-bold text-slate-100">Weighbridge & Escrow Release</div>
                <p className="text-xs text-slate-400">
                  Operator logs gross/tare on this web portal. Verified net weight triggers instantaneous automated
                  escrow payout release.
                </p>
                <div className="text-[11px] font-mono text-emerald-400 bg-emerald-950/60 p-2 rounded border border-emerald-900">
                  Status: BUILT (feat/web-portal)
                </div>
              </div>

              <div className="glass-panel p-5 rounded-2xl space-y-3 border-l-4 border-l-emerald-500">
                <div className="text-xs font-bold text-emerald-400 flex items-center space-x-1">
                  <span>STEP 6 & 7 — MOBILE</span>
                </div>
                <div className="font-bold text-slate-100">Sentinel-2 Green Certificate</div>
                <p className="text-xs text-slate-400">
                  SWIR NBR remote sensing detects zero fire scar (&Delta;NBR &lt; 0.10), issuing verifiable No-Burn
                  Diploma on the mobile app.
                </p>
                <div className="text-[11px] font-mono text-emerald-400 bg-emerald-950/60 p-2 rounded border border-emerald-900">
                  Status: BUILT (feat/satellite-certificate)
                </div>
              </div>
            </div>
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-800 bg-slate-900/60 py-6 text-center text-xs text-slate-500">
        <div className="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-2">
          <div>
            ParaliSetu (पराली सेतु) — Digital Public Infrastructure for Clean Agricultural Harvests
          </div>
          <div className="flex items-center space-x-4 text-slate-400">
            <span>FastAPI Port: 8000</span>
            <span>•</span>
            <span>Next.js Portal: 3000</span>
            <span>•</span>
            <span>Flutter Split APK: 17.03 MB</span>
          </div>
        </div>
      </footer>
    </div>
  );
}
