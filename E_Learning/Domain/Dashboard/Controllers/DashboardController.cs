using E_Learning.Domain.Dashboard.Interface;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace E_Learning.Domain.Dashboard.Controllers
{
    [ApiController]
    [Route("api/dashboard")]
    [Authorize]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet("user")]
        public async Task<IActionResult> GetUserDashboard()
        {
            var userId = GetUserId();
            var result = await _dashboardService.GetUserDashboardAsync(userId);
            return Ok(result);
        }

        [HttpGet("admin")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAdminDashboard()
        {
            var result = await _dashboardService.GetAdminDashboardAsync();
            return Ok(result);
        }

        private Guid GetUserId()
        {
            var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value
                              ?? User.FindFirst("sub")?.Value
                              ?? User.FindFirst("userId")?.Value
                              ?? User.FindFirst("UserId")?.Value;

            if (string.IsNullOrWhiteSpace(userIdClaim))
                throw new UnauthorizedAccessException("User id claim not found.");

            return Guid.Parse(userIdClaim);
        }
    }
}