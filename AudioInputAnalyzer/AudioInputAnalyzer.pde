/**
  * This sketch demonstrates how to use an FFT to analyze
  * the audio being generated by an AudioPlayer.
  * <p>
  * FFT stands for Fast Fourier Transform, which is a 
  * method of analyzing audio that allows you to visualize 
  * the frequency content of a signal. You've seen 
  * visualizations like this before in music players 
  * and car stereos.
  * <p>
  * For more information about Minim and additional features, 
  * visit http://code.compartmental.net/minim/
  */

import ddf.minim.analysis.*;
import ddf.minim.*;

Minim       minim;
AudioInput audioIn;
FFT         fft;
BeatDetect beatFreq, beatSound;
BeatListener bl;

float kickSize, snareSize, hatSize, eRadius;

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioSource source;
  
  BeatListener(BeatDetect beat, AudioSource source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }
  
  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }
  
  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}

void setup()
{
  size(512, 200, P3D);
  
  minim = new Minim(this);
  
  // specify that we want the audio buffers of the AudioPlayer
  // to be 1024 samples long because our FFT needs to have 
  // a power-of-two buffer size and this is a good size.
  audioIn = minim.getLineIn(Minim.MONO, 1024);
  
  
  // create an FFT object that has a time-domain buffer 
  // the same size as audioIn's sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( audioIn.bufferSize(), audioIn.sampleRate() );
  
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beatFreq = new BeatDetect(audioIn.bufferSize(), audioIn.sampleRate());
  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  // note that what sensitivity you choose will depend a lot on what kind of audio 
  // you are analyzing. in this example, we use the same BeatDetect object for 
  // detecting kick, snare, and hat, but that this sensitivity is not especially great
  // for detecting snare reliably (though it's also possible that the range of frequencies
  // used by the isSnare method are not appropriate for the song).
  beatFreq.setSensitivity(300);  
  kickSize = snareSize = hatSize = 16;
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beatFreq, audioIn);  
  textFont(createFont("Helvetica", 16));
  textAlign(CENTER);
  
  // a beat detection object song SOUND_ENERGY mode with a sensitivity of 10 milliseconds
  beatSound = new BeatDetect();
  ellipseMode(RADIUS);
  eRadius = 20;

}

void draw()
{
  background(0);
  stroke(255);
  // audio attributes: band, amplitude, waveform
  
  // perform a forward FFT on the samples in audioIn's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward( audioIn.mix );
  
  for(int i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    line( i, height/2, i, height/2 - fft.getBand(i)*4 );
    line( i, height/2, i, height/2 + fft.getBand(i)*4 );
  }
  
  
  // draw the waveforms
  // the values returned by left.get() and right.get() will be between -1 and 1,
  // so we need to scale them up to see the waveform
  // note that if the file is MONO, left.get() and right.get() will return the same value
  for(int i = 0; i < audioIn.bufferSize() - 1; i++)
  {
    float x1 = map( i, 0, audioIn.bufferSize(), 0, width );
    float x2 = map( i+1, 0, audioIn.bufferSize(), 0, width );
    line( x1, 100 + audioIn.mix.get(i)*50, x2, 100 + audioIn.mix.get(i+1)*50 );
  }
  
  // volume visualization
  noStroke();
  fill( 255, 128 );
  rect( 0, 0, audioIn.mix.level()*width, height );

  // beat detection  
  // draw a green rectangle for every detect band
  // that had an onset this frame
  float rectW = width / beatFreq.detectSize();
  for(int i = 0; i < beatFreq.detectSize(); ++i)
  {
    // test one frequency band for an onset
    if ( beatFreq.isOnset(i) )
    {
      fill(0,200,0);
      rect( i*rectW, 0, rectW, height);
    }
  }
  
  // draw an orange rectangle over the bands in 
  // the range we are querying
  int lowBand = 5;
  int highBand = 15;
  // at least this many bands must have an onset 
  // for isRange to return true
  int numberOfOnsetsThreshold = 4;
  if ( beatFreq.isRange(lowBand, highBand, numberOfOnsetsThreshold) )
  {
    fill(232,179,2,200);
    rect(rectW*lowBand, 0, (highBand-lowBand)*rectW, height);
  }
  
  if ( beatFreq.isKick() ) kickSize = 32;
  if ( beatFreq.isSnare() ) snareSize = 32;
  if ( beatFreq.isHat() ) hatSize = 32;
  
  fill(255);
    
  textSize(kickSize);
  text("KICK", width/4, height/2);
  
  textSize(snareSize);
  text("SNARE", width/2, height/2);
  
  textSize(hatSize);
  text("HAT", 3*width/4, height/2);
  
  kickSize = constrain(kickSize * 0.95, 16, 32);
  snareSize = constrain(snareSize * 0.95, 16, 32);
  hatSize = constrain(hatSize * 0.95, 16, 32);
  
  // sound energy ellipse
  beatSound.detect(audioIn.mix);
  float a = map(eRadius, 20, 80, 60, 255);
  fill(60, 255, 0, a);
  if ( beatSound.isOnset() ) eRadius = 80;
  ellipse(width/2, height/2, eRadius, eRadius);
  eRadius *= 0.95;
  if ( eRadius < 20 ) eRadius = 20;  
}