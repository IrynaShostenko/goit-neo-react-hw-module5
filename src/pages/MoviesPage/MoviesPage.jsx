import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { searchMovies } from "../../services/tmdb";
import MovieList from "../../components/MovieList/MovieList";
import css from "./MoviesPage.module.css";

function MoviesPage() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [params, setParams] = useSearchParams();
  const query = params.get("query") ?? "";

  useEffect(() => {
    if (!query) { setMovies([]); return; }
    (async () => {
      try {
        setLoading(true);
        setMovies(await searchMovies(query));
      } catch {
        setError("Search failed");
      } finally {
        setLoading(false);
      }
    })();
  }, [query]);

  const onSubmit = (e) => {
    e.preventDefault();
    const value = e.currentTarget.elements.search.value.trim();
    setParams(value ? { query: value } : {});
  };

  return (
    <main className={css.main}>
      <h1>Search movies</h1>
      <form onSubmit={onSubmit} className={css.form}>
        <input name="search" defaultValue={query} placeholder="Movie title…" />
        <button type="submit">Search</button>
      </form>

      {loading && <p>Loading…</p>}
      {error && <p>{error}</p>}
      <MovieList movies={movies} />
    </main>
  );
}

export default MoviesPage;