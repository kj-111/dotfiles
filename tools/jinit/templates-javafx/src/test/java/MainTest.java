import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

class MainTest {

    @Test
    void greetingContainsProjectName() {
        var greeting = Main.greeting();

        assertNotNull(greeting);
        assertTrue(greeting.startsWith("Hello"));
        assertEquals("Hello from __PROJECT_NAME__", greeting);
    }
}
