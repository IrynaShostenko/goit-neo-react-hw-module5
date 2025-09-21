import { useEffect, useState } from "react";
import { getTrending } from "../../services/tmdb";
import MovieList from "../../components/MovieList/MovieList";
import css from "./HomePage.module.css";

function HomePage() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setMovies(await getTrending());
      } catch (e) {
        console.error(e);
        setError("Failed to load trending movies");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  return (
    <main className={css.main}>
      <h1>Trending today</h1>
      {loading && <p>Loading…</p>}
      {error && <p>{error}</p>}
      <MovieList movies={movies} />
    </main>
  );
}

export default HomePage;
