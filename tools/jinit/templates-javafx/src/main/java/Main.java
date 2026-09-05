import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.control.Label;
import javafx.scene.layout.StackPane;
import javafx.stage.Stage;

public class Main extends Application {

    @Override
    public void start(Stage stage) {
        var label = new Label(greeting());
        var scene = new Scene(new StackPane(label), 640, 400);
        stage.setTitle("__PROJECT_NAME__");
        stage.setScene(scene);
        stage.show();
    }

    public static void main(String[] args) {
        System.out.println(greeting());
        launch(args);
    }

    static String greeting() {
        return "Hello from __PROJECT_NAME__";
    }
}
