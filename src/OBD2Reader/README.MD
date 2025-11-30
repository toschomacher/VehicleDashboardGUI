✅ 1. Updated C++ Program With More PIDs (including AFR)

This version requests:

Engine RPM (010C)

Vehicle speed (010D)

Coolant temperature (0105)

Throttle position (0111)

Intake temperature (010F)

Mass air flow (MAF) (0110)

Air–Fuel Ratio (AFR) using wideband O2 PIDs:

0114, 0115, 0116, 0117 (depends on car – Toyota usually uses 0114)

AFR formula (for wideband O2 sensor):
AFR = 14.7 × (2 × Value / 65535)
(Value comes from two bytes A and B → A*256 + B)

📦 2. How to Compile on Raspberry Pi

Run:

g++ -o obd_reader obd_reader.cpp


Then:

sudo ./obd_reader

🔌 3. What You Do After Compiling

Start the car (ignition ON, engine running recommended).

Plug the ELM327 into the car’s OBD port.

Plug the USB end into the Raspberry Pi.

Check that it appeared as a device:

ls /dev/ttyUSB*


You should see:

/dev/ttyUSB0


Run your program:

sudo ./obd_reader


That's it — no other setup is required.

Your C++ program handles all ELM initialization (ATZ, ATE0, protocol setup, etc.).

🔧 4. Baud Rate: What to Use and How to Know if It's Wrong
Default ELM327 USB devices use:
38400 baud

If that fails, try:
9600
115200
230400


Modify in code:

set_interface_attribs(fd, B115200);

How you know the baud rate is correct
✔ Correct baud rate

You see readable ASCII text like:

OK
41 0C 1A F8
>


AT commands respond normally

✘ Wrong baud rate

Output looks like garbage characters:

ÿþýø^@#@!!~


No OK

No > prompt

Random symbols or nothing printed

🚗 5. How OBD-II / ELM327 Communication Works (Simplified)

Your understanding is very close — here’s the clean explanation:

✔ Step-by-step

Your program sends an OBD-II request, e.g.:

010C   (Engine RPM)


ELM327 converts this to the correct low-level protocol (CAN, ISO, KWP, etc.)

The car ECU receives the request

ECU responds with a message:

41 0C 1A F8


ELM327 forwards this to you over USB

The program decodes the values (e.g., RPM = ((A*256)+B)/4)

You are not requesting memory addresses.
You are requesting PIDs defined in the OBD-II standard.

🚀 What Happens Now?

Once your program is compiled:

✔ Plug in ELM327
✔ Plug into the car
✔ Start engine
✔ Run program
✔ See real-time telemetry

The code initializes the ELM327, sends PID requests, and prints live data once per second.