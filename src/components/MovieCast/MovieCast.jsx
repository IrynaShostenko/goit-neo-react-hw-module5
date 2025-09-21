import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { getMovieCredits } from "../../services/tmdb";
import { IMG } from "../../utils/img";
import css from "./MovieCast.module.css";

function MovieCast() {
  const { movieId } = useParams();
  const [cast, setCast] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    (async () => {
      try {
        setLoading(true);
        setCast(await getMovieCredits(movieId));
      } catch {
        setError("Failed to load cast");
      } finally {
        setLoading(false);
      }
    })();
  }, [movieId]);

  if (loading) return <p>Loading cast…</p>;
  if (error) return <p>{error}</p>;
  if (!cast?.length) return <p>No cast information.</p>;

  return (
    <ul className={css.grid}>
      {cast.map(({ id, name, character, profile_path }) => (
        <li key={id} className={css.card}>
          <img src={IMG.avatar(profile_path)} alt={name} />
          <p><b>{name}</b></p>
          <p>Character: {character || "—"}</p>
        </li>
      ))}
    </ul>
  );
}

export default MovieCast;