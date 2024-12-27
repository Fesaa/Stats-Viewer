package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"net/http/cookiejar"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cache"
)

func main() {
	jar, err := cookiejar.New(nil)
	if err != nil {
		log.Fatalf("Failed to create cookie jar: %v", err)
	}
	client := &http.Client{
		Jar: jar,
	}

	app := fiber.New()

	app.Use(cache.New(cache.Config{
		Expiration:   time.Hour,
		CacheControl: true,
	}))

	app.Get("*", func(c *fiber.Ctx) error {
		fmt.Println(c.OriginalURL())
		targetURL := "https://bestat.economie.fgov.be/bestat/api" + c.OriginalURL()
		fmt.Println("Proxying to:", targetURL)

		req, err := http.NewRequest("GET", targetURL, nil)
		if err != nil {
			return err
		}

		res, err := client.Do(req)
		if err != nil {
			return err
		}
		defer res.Body.Close()

		for k, v := range res.Header {
			for _, val := range v {
				c.Response().Header.Add(k, val)
			}
		}

		data, err := io.ReadAll(res.Body)
		if err != nil {
			return err
		}

		return c.Status(res.StatusCode).Send(data)
	})

	log.Println("Server is running on http://localhost:8080")
	log.Fatal(app.Listen(":8080"))
}
