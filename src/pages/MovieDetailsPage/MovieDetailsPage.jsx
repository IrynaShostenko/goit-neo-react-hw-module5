import { useEffect, useRef, useState } from "react";
import { Link, NavLink, Outlet, useLocation, useParams } from "react-router-dom";
import { getMovieDetails } from "../../services/tmdb";
import { IMG } from "../../utils/img";
import css from "./MovieDetailsPage.module.css";

function MovieDetailsPage() {
  const { movieId } = useParams();
  const location = useLocation();
  const backRef = useRef(location.state?.from ?? "/movies");

  const [movie, setMovie] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setMovie(await getMovieDetails(movieId));
      } catch {
        setError("Cannot load movie details");
      } finally {
        setLoading(false);
      }
    })();
  }, [movieId]);

  if (loading) return <p className={css.box}>Loading…</p>;
  if (error) return <p className={css.box}>{error}</p>;
  if (!movie) return null;

  const { poster_path, title, release_date, vote_average, overview, genres } =
    movie;

  return (
    <main className={css.main}>
      <Link className={css.back} to={backRef.current}>← Go back</Link>

      <div className={css.hero}>
        <img src={IMG.poster(poster_path)} alt={title} />
        <div>
          <h2>
            {title} {!!release_date && `(${release_date.slice(0, 4)})`}
          </h2>
          <p>User Score: {Math.round(vote_average * 10)}%</p>
          <h3>Overview</h3>
          <p>{overview || "No overview"}</p>
          <h3>Genres</h3>
          <p>{genres?.map((g) => g.name).join(" ") || "—"}</p>
        </div>
      </div>

      <section className={css.subnav}>
        <p>Additional information</p>
        <ul>
          <li><NavLink to="cast">Cast</NavLink></li>
          <li><NavLink to="reviews">Reviews</NavLink></li>
        </ul>
      </section>

      <Outlet />
    </main>
  );
}

export default MovieDetailsPage;