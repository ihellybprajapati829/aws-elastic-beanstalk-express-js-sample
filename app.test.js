const request = require("supertest");
const app = require("./app");

describe("GET/", () => {
  it("responds with Hello World! and status 200", async () => {
    const res = await request(app).get("/");
    expect(res.statusCode).toBe(200);
    expect(res.text).toBe("Hello World!");
  });
});

