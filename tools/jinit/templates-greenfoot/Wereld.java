import greenfoot.*;

public class Wereld extends World {
    public Wereld() {
        super(600, 400, 1);
        addObject(new Speler(), getWidth() / 2, getHeight() / 2);
    }

    public void act() {
    }
}
