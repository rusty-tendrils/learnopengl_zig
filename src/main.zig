const std = @import("std");
const c = @cImport({
    @cDefine("GLFW_INCLUDE_NONE", {});
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

const WIDTH: c_int = 800;
const HEIGHT: c_int = 600;
const LOG_SIZE: c_int = 512;

const vertexShaderSource =
    \\#version 460 core
    \\layout (location = 0) in vec3 aPos;
    \\void main()
    \\{
    \\   gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
    \\}
;

const fragmentShaderSource =
    \\#version 460 core
    \\out vec4 FragColor;
    \\void main()
    \\{
    \\   FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
    \\}
;

pub fn main() !void {
    // GLFW init
    _ = c.glfwInit();
    defer c.glfwTerminate();

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 6);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(WIDTH, HEIGHT, "LearnOpenGL", null, null);
    if (window == null) {
        c.glfwTerminate();
        return error.GLFWInitFailed;
    }
    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == 0) {
        return error.GLADInitFailed;
    }

    c.glViewport(0, 0, WIDTH, HEIGHT);

    _ = c.glfwSetFramebufferSizeCallback(window, framebuffer_size_callback);

    // Vertex Shader
    const vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);
    c.glShaderSource(vertexShader, 1, @ptrCast(&vertexShaderSource), null);
    c.glCompileShader(vertexShader);

    var success: c_int = undefined;
    const infoLog: *[LOG_SIZE]c.GLchar = undefined;
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &success);

    if (success == 0) {
        c.glGetShaderInfoLog(vertexShader, LOG_SIZE, null, infoLog);
        std.debug.print("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n {s}", .{infoLog});
    }

    // Fragment Shader
    const fragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    c.glShaderSource(fragmentShader, 1, @ptrCast(&fragmentShaderSource), null);
    c.glCompileShader(fragmentShader);

    c.glGetShaderiv(fragmentShader, c.GL_COMPILE_STATUS, &success);

    if (success == 0) {
        c.glGetShaderInfoLog(fragmentShader, LOG_SIZE, null, infoLog);
        std.debug.print("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n {s}", .{infoLog});
    }

    // Linking
    const shaderProgram = c.glCreateProgram();

    c.glAttachShader(shaderProgram, vertexShader);
    c.glAttachShader(shaderProgram, fragmentShader);
    c.glLinkProgram(shaderProgram);

    // TODO: Put these in a fn and use defer for these later
    c.glDeleteShader(vertexShader);
    c.glDeleteShader(fragmentShader);

    c.glGetProgramiv(shaderProgram, c.GL_COMPILE_STATUS, &success);

    if (success == 0) {
        c.glGetProgramInfoLog(shaderProgram, LOG_SIZE, null, infoLog);
        std.debug.print("ERROR::SHADER::PROGRAM::COMPILATION_FAILED\n {s}", .{infoLog});
    }

    const vertices = [_]f32{
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
        -0.0, 0.5,  0.0,
    };

    var VAO: c_uint = undefined;
    c.glGenVertexArrays(1, &VAO);
    c.glBindVertexArray(VAO);

    var VBO: c_uint = undefined;
    c.glGenBuffers(1, &VBO);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    c.glBufferData(c.GL_ARRAY_BUFFER, @sizeOf(@TypeOf(vertices)), &vertices, c.GL_STATIC_DRAW);

    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), @ptrCast(&0));
    c.glEnableVertexAttribArray(0);

    // Unbinding
    c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);
    c.glBindVertexArray(0);

    // Render loop
    while (c.glfwWindowShouldClose(window) == 0) {
        processInput(window);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shaderProgram);
        c.glBindVertexArray(VAO);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn framebuffer_size_callback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}

fn processInput(window: ?*c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, c.GL_TRUE);
    }
}
