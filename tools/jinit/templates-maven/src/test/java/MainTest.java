import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.assertAll;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MainTest {

    @Test
    void greetingContainsProjectName() {
        var greeting = Main.greeting();

        assertNotNull(greeting);
        assertTrue(greeting.startsWith("Hello"));
        assertEquals("Hello from __PROJECT_NAME__", greeting);
    }

    @Test
    void evenNumbersCanBeChecked() {
        assertTrue(Main.isEven(2));
        assertFalse(Main.isEven(3));
    }

    @Test
    void relatedAssertionsCanBeGrouped() {
        assertAll(
                () -> assertEquals(2, Main.divide(4, 2)),
                () -> assertEquals(-2, Main.divide(-4, 2)));
    }

    @Test
    void invalidInputThrowsException() {
        var exception = assertThrows(ArithmeticException.class, () -> Main.divide(4, 0));

        assertEquals("/ by zero", exception.getMessage());
    }

    @Test
    void mainPrintsGreetingToConsole() {
        var output = new ByteArrayOutputStream();
        var originalOut = System.out;

        try {
            System.setOut(new PrintStream(output, true, StandardCharsets.UTF_8));
            Main.main(new String[0]);
        } finally {
            System.setOut(originalOut);
        }

        assertEquals("Hello from __PROJECT_NAME__" + System.lineSeparator(), output.toString(StandardCharsets.UTF_8));
    }
}
