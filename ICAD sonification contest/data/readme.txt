Each of the two scenarios has a different folder.
Data is provided by single- and two-channel Wave files.
This is simply for convenience. The nominal sampling rate
of 48 kHz is arbitrary.

Please refer to the metadata.txt files to learn about
the meaning of the channels and the
scaling of each dimension into the normalised range
of -1 ... +1.

Cluster has four satellites C1, C2, C4, C4.
THEMIS has four satellites tha, thb, thc, thd.
For each satellite, we have the magnetic field vector
with components x, y, z and magnitude t. We also
have the positions of each satelllite over time
as x, y, z. The time tags of the data are provided
in the separate time files. Note that due to to
drop-outs, the sample rate is only approximately
constant (for example, in Cluster, the data is
sampled roughly at 22 Hz). You can chooser whether
you want to take this in consideration, or if you
want to simplify the approach by assuming time to
pass at relatively constant speed.

:::: Example ::::

We look at the first Cluster satellite, all files
beginning with "C1_...".

We find the x and y components of the magnetic field
vector (B-field) in the file ending with "_B_xy.wav" 
and the left channel of "_B_zt.wav". The right channel 
of "_B_zt.wav" is the magnitude, i.e. 
sqrt(x^2 + y^2 + z^2). In the floating point data
of the normalized files we find as the first sample:

x0_f = 0.386
y0_f = -0.184
z0_f = 0.013
t0_f = 0.428

We verify: sqrt(0.386^2 + -0.184^2 + 0.013^2) = 0.428

To know the values in nano-Tesla, we find the entry
"Field scale: 200.000000" in the metadata.txt, and get

x0 = x0_f * 200 nT = 77.2 nT
y0 = y0_f * 200 nT = -36.8 nT
z0 = z0_f * 200 nT = 2.6 nT
t0 = t0_f * 200 nT = 85.6 nT

A look at Cluster-Data.ps shows that is correct.

:::: Remarks ::::

When looking at the spectrum or sonogram, you will
find some static frequencies or slowly moving
glissandi. These are _artifacts_ from the
satellite and measuring apparatus.

Most noticable, there is a strong
component at around 0.18 Hz. This is for example
related to the self-rotation (spin frequency)
of the satellite that still appears despite the 
data having been demodulated.

The scientifically interesting events in the
magnetic field are of rather short duration and
appear as broadband "distortions".

