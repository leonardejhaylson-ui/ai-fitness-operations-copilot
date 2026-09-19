import { render, screen } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { BootstrapStatus } from "./bootstrap-status";

describe("BootstrapStatus", () => {
  it("states that business capabilities are not implemented", () => {
    render(<BootstrapStatus />);
    expect(screen.getByRole("heading", { name: "Repository bootstrap ready" })).toBeInTheDocument();
    expect(screen.getByText(/intentionally not implemented/i)).toBeInTheDocument();
  });
});
