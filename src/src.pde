import fisica.*;
import processing.sound.*;
import gifAnimation.*;
FWorld world;
SoundFile drumSound;
SoundFile guitar1Sound;
SoundFile guitar2Sound;
FFT guitar1Fft;
FFT drumFft;
Amplitude amp;

int COUNT = 10;
int MINSIZE = 10;
int MAXSIZE = 50;
float MINSPEED = 0.5;
float MAXSPEED = 10;
int BOUNCE_HEIGHT = 300;
int FRAME_RATE = 18;
String BG_COLOR = "#171d21";
String BOTTOM_NAME = "bottom";
PImage img;
Gif bosatsu;
PImage background;
PImage tama1;
PImage tama2;
PImage tama3;
PImage tama4;
PImage tama5;
ArrayList < PImage > tamas = new ArrayList < PImage > ();

void setup() {
    size(1000, 1000);
    background(255);
    frameRate(FRAME_RATE);
    img = loadImage("../images/bosatsu.png");
    bosatsu = new Gif (this, "../images/bosatsu_mepachi.gif");
    bosatsu.play();
    background = loadImage("../images/background.png");
    background.resize(1000, 1000);
    setupTama();
    setupWorld();
    setupSound();
    setupFft();
    setupAmplitude();
    playSound();
    drumFft.input(drumSound);
    guitar1Fft.input(guitar1Sound);
    amp.input(guitar2Sound);
    drawCollision();
}

void draw() {
    resetBackground();
    push();
    drawBosatsu();
    world.step();
    world.draw();
    pop();
    drawSpectrumGraph();
    fallBubbles();
    if (amp.analyze() < 0.1) {
        removeBubble();
    }
}

void setupTama() {
    tama1 = loadImage("../images/tama1.png");
    tama2 = loadImage("../images/tama2.png");
    tama3 = loadImage("../images/tama3.png");
    tama4 = loadImage("../images/tama4.png");
    tama5 = loadImage("../images/tama5.png");
    tamas.add(tama1);
    tamas.add(tama2);
    tamas.add(tama3);
    tamas.add(tama4);
    tamas.add(tama5);
}

/**
* スペクトラムやボールが重ねて描画されないようにdraw()ごとに背景でresetする
*/
void resetBackground() {
    background(background);
}

void setupWorld() {
    Fisica.init(this);
    world = new FWorld();
    world.setEdges();
    world.bottom.setName(BOTTOM_NAME);
    world.setGravity(0,5000);
}

void setupSound() {
    drumSound = new SoundFile(this, "../media/bosatsu_drum.mp3");
    guitar1Sound = new SoundFile(this, "../media/bosatsu_guitar1.mp3");
    guitar2Sound = new SoundFile(this, "../media/bosatsu_guitar2.mp3");
}

void setupFft() {
    drumFft = new FFT(this);
    guitar1Fft = new FFT(this);
}

void playSound() {
    drumSound.play();
    guitar1Sound.play();
    guitar2Sound.play();
}

void setupAmplitude() {
    amp = new Amplitude(this);
}

void drawSpectrumGraph() {
    float[] drumSpectrum = drumFft.analyze();
    for (int i = 0; i < drumSpectrum.length; i++) {
        float mapped = map(drumSpectrum[i], 0,1,0,100);
        float y = map(drumSpectrum[i], 0,0.1, 0, height);
        noStroke();
        fill(255, i, 255);
        rect(i * 5, height - y, 4, y);
    }
}

void fallBubbles() {
    float[] guitar1Spectrum = guitar1Fft.analyze();
    for (int i = 0; i < guitar1Spectrum.length; i++) {
        float mapped = map(guitar1Spectrum[i], 0,1,0,100);
        if (mapped > 30) {
            addBubble(mapped);
        }
    }
}

void drawBosatsu() {
    float imageX = -200;
    float imageY = 130;
    float width = 1140;
    float height = 864;
    image(bosatsu, imageX, imageY, width, height);
}

void drawCollision() {
    FBox collision = new FBox(150, 50);
    collision.setPosition(250, 700);
    collision.setStatic(true);
    collision.setGrabbable(false);
    collision.setNoFill();
    collision.setNoStroke();
    collision.setRestitution(0.3);
    collision.setRotation(0.2);
    world.add(collision);
}

void addBubble(float spectrum) {
    float zDist = random(0, 100);
    float x = random(200, 260);
    float y = 0;
    float size = random(MINSIZE, MAXSIZE);
    float speed = map(zDist, 0, 1, MINSPEED, MAXSPEED);
    PImage tama = tamas.get(int(random(0, tamas.size()))).copy();
    Bubble bubble = new Bubble(x, y, size, speed, tama);
    world.add(bubble.body);
}

int getBubbleCount() {
    return world.getBodies().size();
}

void removeBubble() {
    ArrayList<FBody> bodies = world.getBodies();
    for (FBody body : bodies) {
        ArrayList<FContact> contacts = body.getContacts();
        for (FContact contact : contacts) {
            if (contact.getBody1().getName() == BOTTOM_NAME && body.getName() != BOTTOM_NAME) {
                world.remove(body);
            }
        }
    }
}

class Bubble{
    public FCircle body;
    public Bubble(float x, float y, float size, float speed, PImage image) {
        image.resize(int(size), int(size));
        this.body = new FCircle(size);
        this.body.setPosition(x, y);
        this.body.attachImage(image);
        this.body.setNoStroke();
        this.body.setRestitution(0.4);
        this.body.setVelocity(0, speed);
    }
    public float getY() {
        return body.getY();
    }
}

class Position {
    public float x;
    public float y;
    public Position(float x, float y) {
        this.x = x;
        this.y = y;
    }
}