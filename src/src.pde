import fisica.*;
import processing.sound.*;
import gifAnimation.*;
FWorld world;
SoundFile otherSound;
SoundFile guitar1Sound;
SoundFile guitar2Sound;
SoundFile keySound;
FFT guitar1Fft;
FFT otherFft;
FFT guitar2Fft;
FFT keyFft;
Amplitude keyAmp;
Amplitude guitar1Amp;
Amplitude guitar2Amp;

int COUNT = 10;
int TAMA_MINSIZE = 10;
int TAMA_MAXSIZE = 30;
int HOSHI_MINSIZE = 30;
int HOSHI_MAXSIZE = 50;
float MINSPEED = 0.5;
float MAXSPEED = 10;
int BOUNCE_HEIGHT = 300;
int FRAME_RATE = 30;
final int GTR1 = 1;
final int GTR2 = 2;
final int KEY = 3;

String BG_COLOR = "#171d21";
String BOTTOM_NAME = "bottom";
PImage img;
PImage sora;
Gif bosatsu;
PImage background;
PImage tama1;
PImage tama2;
PImage tama3;
PImage tama4;
PImage tama5;
ArrayList < PImage > tamas = new ArrayList < PImage > ();
PImage star1;
PImage star2;
PImage star3;
PImage star4;
PImage star5;
ArrayList < PImage > stars = new ArrayList < PImage > ();
Cloud kumo;
boolean isSoraShown = false;

void setup() {
    noSmooth();
    size(1000, 1000);
    frameRate(FRAME_RATE);
    img = loadImage("../images/bosatsu.png");
    bosatsu = new Gif (this, "../images/bosatsu_mepachi.gif");
    bosatsu.play();
    background = loadImage("../images/background.png");
    sora = loadImage("../images/sora.png");
    background.resize(1000, 1000);
    sora.resize(1000,1000);
    setupTama();
    setupStar();
    setupWorld();
    setupSound();
    //setupFft();
    setupAmplitude();
    playSound();
    drawCollision();
    kumo = new Cloud("../images/kumo.png", 1, 1000, 300);
}

void draw() {
    toggleSoraShown(guitar2Amp);
    resetBackground(guitar2Amp);
    push();
    kumo.move(isSoraShown);
    drawBosatsu();
    world.step();
    world.draw();
    pop();
    fallBubbles(guitar1Amp, GTR1);
    fallBubbles(guitar2Amp, GTR2);
    fallBubbles(keyAmp, KEY);
    removeBubble();
}

void toggleSoraShown(Amplitude amp) {
    if (amp.analyze() > 0.01) {
        isSoraShown = true;
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

void setupStar() {
    star1 = loadImage("../images/hoshi1.png");
    star2 = loadImage("../images/hoshi2.png");
    star3 = loadImage("../images/hoshi3.png");
    star4 = loadImage("../images/hoshi4.png");
    star5 = loadImage("../images/hoshi5.png");
    stars.add(star1);
    stars.add(star2);
    stars.add(star3);
    stars.add(star4);
    stars.add(star5);
}

/**
* スペクトラムやボールが重ねて描画されないようにdraw()ごとに背景でresetする
*/
void resetBackground(Amplitude amp) {
    background(isSoraShown ? sora : background);
}

void setupWorld() {
    Fisica.init(this);
    world = new FWorld();
    world.setEdges();
    world.bottom.setName(BOTTOM_NAME);
    world.setGravity(0,1500);
}

void setupSound() {
    otherSound = new SoundFile(this, "../media/Other.wav");
    guitar1Sound = new SoundFile(this, "../media/GTR1_REV.wav");
    guitar2Sound = new SoundFile(this, "../media/GTR2_REV.wav");
    keySound = new SoundFile(this, "../media/KEY.wav");
}

void setupFft() {
    otherFft = new FFT(this);
    guitar1Fft = new FFT(this);
    guitar2Fft = new FFT(this, 256);
    keyFft = new FFT(this);
    otherFft.input(otherSound);
    guitar1Fft.input(guitar1Sound);
    guitar2Fft.input(guitar2Sound);
    keyFft.input(keySound);
}

void playSound() {
    otherSound.play();
    guitar1Sound.play();
    guitar2Sound.play();
    keySound.play();
}

void setupAmplitude() {
    keyAmp = new Amplitude(this);
    guitar1Amp = new Amplitude(this);
    guitar2Amp = new Amplitude(this);
    keyAmp.input(keySound);
    guitar1Amp.input(guitar1Sound);
    guitar2Amp.input(guitar2Sound);
}

void fallBubbles(Amplitude amplitude, int sound) {
    float threshold;
    switch(sound) {
        case GTR1:
            threshold = 0.1;
            break;
        case GTR2:
            threshold = 0.2;
            break;
        case KEY:
            threshold = 0.25;
            break;
        default :
        threshold = 0.1;
        break;
    }
    if (amplitude.analyze() > threshold) {
        addBubble(sound);
    }
    // for (int i = 0; i < spectrum.length; i++) {
    //     float mapped;
    //     float threshold;
    //     switch(sound) {
    //         case GTR1:
    //             mapped = map(spectrum[i], 0,1,0,100);
    //             threshold = 10;
    //             break;
    //         case GTR2:
    //             mapped = map(spectrum[i], 0,0.1,0,1000);
    //             threshold = 0.07;
    //             println(mapped);
    //             break;
    //         default :
    //         mapped = map(spectrum[i], 0,1,0,100);
    //         threshold = 15;
    //         break;
    //     }
    //     if (mapped > threshold) {
    //         addBubble(mapped, sound);
    //     }
// }
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

void addBubble(int sound) {
    float zDist = random(0, 100);
    float x = random(200, 260);
    float y = 0;
    float size;
    float speed = map(zDist, 0, 1, MINSPEED, MAXSPEED);
    PImage image;
    switch(sound) {
        case GTR1:
            image = tamas.get((int)random(0, 2)).copy();
            size = random(TAMA_MINSIZE, TAMA_MAXSIZE);
            break;
        case GTR2:
            image = tamas.get((int)random(0, 5)).copy();
            size = random(TAMA_MINSIZE, TAMA_MAXSIZE);
            break;
        default :
        image = stars.get((int)random(0, 5)).copy();
        size = random(HOSHI_MINSIZE, HOSHI_MAXSIZE);
        break;
    }
    Bubble bubble = new Bubble(x, y, size, speed, image);
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

class Bubble {
    public FCircle body;
    public Bubble(float x, float y, float size, float speed, PImage image) {
        image.resize(int(size), int(size));
        this.body = new FCircle(size);
        this.body.setPosition(x, y);
        this.body.attachImage(image);
        this.body.setNoStroke();
        this.body.setRestitution(0.5);
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

class Cloud {
    private PImage cloudImage;
    private int width = 2000;
    private int height = 500;
    private int speed;
    private int positionX;
    private int positionY;
    public Cloud(String imagePath, int speed, int positionX, int positionY) {
        this.cloudImage = loadImage(imagePath);
        this.speed = speed;
        this.positionX = positionX;
        this.positionY = positionY;
    }
    
    public void move(boolean move) {
        if (!move) {
            return;
        }
        this.positionX -= speed;
        image(cloudImage, positionX, positionY, width, height);
    }
}