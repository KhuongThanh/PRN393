using E_Learning.Domain.Favorite.Dtos;

namespace E_Learning.Domain.Favorite.Interface
{
    public interface IFavoriteService
    {
        Task AddFavoriteAsync(Guid userId, Guid wordId);
        Task RemoveFavoriteAsync(Guid userId, Guid wordId);
        Task<List<FavoriteWordDto>> GetFavoritesAsync(Guid userId);
    }
}
